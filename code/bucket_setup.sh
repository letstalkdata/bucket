#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
source config
source code/gen-helper-function.sh
#
#
bucket_setup_init(){
    echo "Performinig initial configuration..."
    sudo apt install -y net-tools > /dev/null 2>&1
    sudo chmod +x bucket
    absPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    absDir=$(dirname $absPath)
    finalDir=$(dirname $absDir)
    msg="if [ -d \"$finalDir\" ] ; then PATH=\"$finalDir:\$PATH\"; fi"
    echo $msg >> ~/.profile
    source ~/.profile
}
#
bucket_setup_profile(){
    echo "Performinig initial profile configuration..."
    ## Setup Profile
    lxc profile show default > preconfig/profile-fixed.sh
    sed -i '/config/d' preconfig/profile-fixed.sh
    sed -i '/description/d' preconfig/profile-fixed.sh
    sed -i 's/name: default/name: <name>/' preconfig/profile-fixed.sh
    #
    sed -i '1s/^/description: LXD profile for <name> bucket\n/' preconfig/profile-fixed.sh
    sed -i '1s/^/  security.privileged: "true"\n/' preconfig/profile-fixed.sh
    sed -i '1s/^/  security.nesting: "true"\n/' preconfig/profile-fixed.sh
    sed -i '1s/^/  raw.lxc: "lxc.apparmor.profile=unconfined\\nlxc.cap.drop= \\nlxc.cgroup.devices.allow=a\\nlxc.mount.auto=proc:rw sys:rw"\n/' preconfig/profile-fixed.sh
    sed -i '1s/^/  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay\n/' preconfig/profile-fixed.sh
    sed -i '1s/^/  limits.memory.swap: "false"\n/' preconfig/profile-fixed.sh
    sed -i '1s/^/  limits.memory: <mem>\n/' preconfig/profile-fixed.sh
    sed -i '1s/^/  limits.cpu: <cpu>\n/' preconfig/profile-fixed.sh
    sed -i '1s/^/config:\n/' preconfig/profile-fixed.sh
    echo "fixed profile created.."
    #
    cpu="1"
    mem="1GB"
    find1="<name>"
    find2="<cpu>"
    find3="<mem>"
    i=1
    for ptype in tiny mini mini2 regular regular2 heavy heavy2 heavy3
    do
        name=$ptype;
        case "$ptype" in
            tiny)   cpu="1";
                    mem="1GB";
                    ;;
            mini)   cpu="1";
                    mem="2GB";
                    ;;
            mini2)  cpu="2";
                    mem="2GB";
                    ;;
            regular) cpu="2";
                    mem="4GB";
                    ;;
            regular2) cpu="4";
                    mem="8GB";
                    ;;
            heavy)  cpu="8";
                    mem="16GB";
                    ;;
            heavy2) cpu="8";
                    mem="32GB"
                    ;;
            heavy3) cpu="8";
                    mem="64GB"
                    ;;
            *) exit 1;
        esac
        yaml=""
        yaml="profile/new-"$name"-profile.yaml"
        sed "s/$find1/$name/" preconfig/profile-fixed.sh > $yaml
        sed -i "s/$find2/$cpu/" $yaml 
        sed -i "s/$find3/$mem/" $yaml
        #
        lxc profile copy default $name
        #
        lxc profile edit $name < $yaml
        #
        rm -rf $yaml
    done
    lxc profile list
    echo -e "${CYAN}All profiles for bucket created successfully${NC}"
}
#
bucket_setup_template_client(){
    echo "Performinig initial client template configuration..."
    lxc launch images:centos/7 sys-client-v1 --profile tiny
    sleep 5s
    echo "Initial bootstarp..."
    cat preconfig/bootstrap-template.sh | lxc exec sys-client-v1 bash
    lxc file push code/kube-flannel.yml sys-client-v1/root/kube-flannel.yml
    echo "Client bootstarp..."
    cat preconfig/bootstrap-client-v1.sh | lxc exec sys-client-v1 bash
    lxc stop sys-client-v1
    echo -e "${CYAN}Client template configured successfully ${NC}"
}
#
bucket_setup_template_node(){
    echo "Performinig initial node template configuration..."
    lxc copy sys-client-v1 sys-node --profile mini2
    lxc start sys-node
    sleep 2s
    cat preconfig/bootstrap-node.sh | lxc exec sys-node bash
    lxc stop sys-node
    echo -e "${CYAN} Node template configured successfully ${NC}"
}
#
bucket_setup_template_k8s(){
    echo "Performinig initial k8s template configuration..."
    lxc copy sys-client-v1 sys-k8s --profile mini2
    lxc start sys-k8s
    sleep 2s
    cat preconfig/bootstrap-k8s.sh | lxc exec sys-k8s bash
    lxc stop sys-k8s
    echo -e "${CYAN} k8s template configured successfully ${NC}"
}
bucket_setup_template_gluster(){
    echo "Performinig initial glusterFS template configuration..."
    lxc launch images:centos/7 sys-gluster --profile mini2
    sleep 5s
    cat preconfig/bootstrap-gluster.sh | lxc exec sys-gluster bash
    lxc stop sys-gluster
    echo -e "${CYAN} glusterFS template configured successfully ${NC}"
}
#
bucket_setup_template_dtr(){
    echo "Performinig initial dtr template configuration..."
    #: '
    lxc copy sys-client-v1 sys-dtr --profile mini
    lxc start sys-dtr
    sleep 2s
    lxc file push images/flannel.tar.gz sys-dtr/root/flannel.tar.gz
    cat preconfig/bootstrap-dtr.sh | lxc exec sys-dtr bash
    #
    if [[ $withBDC == "yes" ]]; then 
        cat preconfig/bdc-images.sh | lxc exec sys-dtr bash
    fi
    #'
    echo -e "${CYAN}dtr template configured successfully ${NC}"
}
#
bucket_setup_template(){
    echo "Performinig initial template configuration..."
    # $fclient $fnode $fdtr $fk8s $ftall
    fclient=$1
    shift
    fnode=$1
    shift
    fdtr=$1
    shift
    fk8s=$1
    shift
    ftall=$1
    #
    if (( $fclient > 0 )); then
        bucket_setup_template_client;
    fi
    if (( $fnode > 0 )); then
        bucket_setup_template_node;
    fi
    if (( $fk8s > 0 )); then
        bucket_setup_template_k8s;
    fi
    if (( $fglust > 0 )); then
        bucket_setup_template_gluster;
    fi
    if (( $fdtr > 0 )); then
        bucket_setup_template_dtr;
    fi
    if (( $ftall > 0 )); then
        bucket_setup_template_client;
        bucket_setup_template_node;
        bucket_setup_template_k8s;
        bucket_setup_template_gluster;
        bucket_setup_template_dtr;
    fi
}
#
bucket_setup() {
    # $finit $fprofile $ftemplate $fsall
    finit=$1
    shift
    fprofile=$1
    shift
    ftemplate=$1
    shift
    fsall=$1
    #
    if (( $ftemplate < 1 )); then
        echo
    fi
    if (( $finit > 0 )); then
        bucket_setup_init;
    fi
    if (( $fprofile > 0 )); then
        bucket_setup_profile;
    fi
    if (( $fsall > 0 )); then
        bucket_setup_init;
        bucket_setup_profile;
        bucket_setup_template 0 0 0 0 1;
    fi
}