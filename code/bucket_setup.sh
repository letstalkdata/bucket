#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
source $BUCKET_HOME/config
source $BUCKET_HOME/code/gen-helper-function.sh
#
#
bucket_setup_init(){
    echo "Performinig initial configuration..."
    sudo snap install lxd
    newgrp lxd
    sudo usermod -aG lxd $USER
    sudo lxd --version
    sudo lxd init --auto
    #
    sudo apt install -y net-tools > /dev/null 2>&1
    sudo chmod +x bucket
    absPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    absDir=$(dirname $absPath)
    finalDir=$(dirname $absDir)
    msg="if [ -d \"$finalDir\" ] ; then PATH=\"$finalDir:\$PATH\"; fi"
    echo $msg >> ~/.profile
    msg2="export BUCKET_HOME=\$finalDir"
    echo $msg2 >> ~/.profile
    source ~/.profile
}
#
bucket_setup_profile(){
    echo "Performinig initial profile configuration..."
    ## Setup Profile
    lxc profile show default > $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '/config/d' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '/description/d' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i 's/name: default/name: <name>/' $BUCKET_HOME/preconfig/profile-fixed.sh
    #
    sed -i '1s/^/description: LXD profile for <name> bucket\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '1s/^/  security.privileged: "true"\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '1s/^/  security.nesting: "true"\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '1s/^/  raw.lxc: "lxc.apparmor.profile=unconfined\\nlxc.cap.drop= \\nlxc.cgroup.devices.allow=a\\nlxc.mount.auto=proc:rw sys:rw"\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '1s/^/  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '1s/^/  limits.memory.swap: "false"\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '1s/^/  limits.memory: <mem>\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '1s/^/  limits.cpu: <cpu>\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
    sed -i '1s/^/config:\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
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
        yaml=$BUCKET_HOME"/profile/new-"$name"-profile.yaml"
        sed "s/$find1/$name/" $BUCKET_HOME/preconfig/profile-fixed.sh > $yaml
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
bucket_setup_template_init() {
    echo "Performinig initial template configuration..."
    lxc launch images:centos/7 sys-init --profile regular
    sleep 8s
    echo "Initial bootstarp..."
    cat $BUCKET_HOME/preconfig/bootstrap-template.sh | lxc exec sys-init bash
    lxc file push $BUCKET_HOME/code/kube-flannel.yml sys-init/root/kube-flannel.yml
    lxc stop sys-init
    echo -e "${CYAN}Initial template configured successfully ${NC}"
}
bucket_setup_template_client(){
    echo "Performinig initial client template configuration..."
    lxc copy sys-init sys-client-v1 --profile mini2
    lxc start sys-client-v1
    sleep 5s
    cat $BUCKET_HOME/preconfig/bootstrap-client-v1.sh | lxc exec sys-client-v1 bash
    lxc stop sys-client-v1
    echo -e "${CYAN}Client template configured successfully ${NC}"
}
#
bucket_setup_template_node(){
    echo "Performinig initial node template configuration..."
    lxc copy sys-init sys-node --profile mini2
    lxc start sys-node
    sleep 3s
    cat $BUCKET_HOME/preconfig/bootstrap-node.sh | lxc exec sys-node bash
    lxc stop sys-node
    echo -e "${CYAN} Node template configured successfully ${NC}"
}
#
bucket_setup_template_mysql() {
    lxc copy sys-init sys-mysql --profile mini2
    lxc start sys-mysql
    sleep 3s
    cat $BUCKET_HOME/preconfig/bootstrap-mysql.sh | lxc exec sys-mysql bash
    lxc stop sys-mysql
    echo -e "${CYAN}MySQL template configured successfully ${NC}"
}
bucket_setup_template_mssql() {
    lxc copy sys-init sys-mssql --profile mini2
    lxc start sys-mssql
    sleep 3s
    cat $BUCKET_HOME/preconfig/bootstrap-mssql.sh | lxc exec sys-mssql bash
    lxc stop sys-mssql
    echo -e "${CYAN}MSSQL template configured successfully ${NC}"
}
#
bucket_setup_template_k8s(){
    echo "Performinig initial k8s template configuration..."
    lxc copy sys-init sys-k8s --profile mini2
    lxc start sys-k8s
    sleep 2s
    cat $BUCKET_HOME/preconfig/bootstrap-k8s.sh | lxc exec sys-k8s bash
    lxc stop sys-k8s
    echo -e "${CYAN} k8s template configured successfully ${NC}"
}
bucket_setup_template_gluster(){
    echo "Performinig initial glusterFS template configuration..."
    lxc copy sys-init sys-gluster --profile mini2
    sleep 3s
    cat $BUCKET_HOME/preconfig/bootstrap-gluster.sh | lxc exec sys-gluster bash
    lxc stop sys-gluster
    echo -e "${CYAN} glusterFS template configured successfully ${NC}"
}
#
bucket_setup_template_dtr(){
    echo "Performinig initial dtr template configuration..."
    #: '
    lxc copy sys-init sys-dtr --profile mini2
    lxc start sys-dtr
    sleep 2s
    lxc file push $BUCKET_HOME/images/flannel.tar.gz sys-dtr/root/flannel.tar.gz
    cat $BUCKET_HOME/preconfig/bootstrap-dtr.sh | lxc exec sys-dtr bash
    #
    if [[ $withBDC == "yes" ]]; then 
        cat $BUCKET_HOME/preconfig/bdc-images.sh | lxc exec sys-dtr bash
    fi
    #'
    echo -e "${CYAN}dtr template configured successfully ${NC}"
}
#
bucket_setup_template(){
    echo "Performinig initial template configuration..."
    # $fclient $fnode $fmysql $fmssql $fk8s $fglust $fdtr $ftall
    fclient=$1
    shift
    fnode=$1
    shift
    fmysql=$1
    shift
    fmssql=$1
    shift
    fk8s=$1
    shift
    fglust=$1
    shift
    fdtr=$1
    shift
    ftall=$1
    #
    #echo "fmysql=$fmysql"
    initName="sys-init"
    clientName="sys-client-v1"
    nodeName="sys-node"
    mysqlName="sys-mysql"
    mssqlName="sys-mssql"
    k8sName="sys-k8s"
    glusterName="sys-gluster"
    dtrName="sys-dtr"
    #
    testInit=$(lxc list $initName --format csv -c n)
    if [[ ! $testInit ]]; then 
        bucket_setup_template_init;
    fi
    #
    if (( $fclient > 0 )); then
        testClient=$(lxc list $clientName --format csv -c n)
        if [[ ! $testClient ]]; then 
            bucket_setup_template_client;
        fi
    fi
    if (( $fnode > 0 )); then
        testNode=$(lxc list $nodeName --format csv -c n)
        if [[ ! $testNode ]]; then 
            bucket_setup_template_node;
        fi
    fi
    if (( $fmysql > 0 )); then
        testMysql=$(lxc list $mysqlName --format csv -c n)
        if [[ ! $testMysql ]]; then 
            bucket_setup_template_mysql;
        fi
    fi
    if (( $fmssql > 0 )); then
        testMssql=$(lxc list $mssqlName --format csv -c n)
        if [[ ! $testMssql ]]; then 
            bucket_setup_template_mssql;
        fi
    fi
    if (( $fk8s > 0 )); then
        testK8s=$(lxc list $k8sName --format csv -c n)
        if [[ ! $testK8s ]]; then 
            bucket_setup_template_k8s;
        fi
    fi
    if (( $fglust > 0 )); then
        testGluster=$(lxc list $glusterName --format csv -c n)
        if [[ ! $testGluster ]]; then 
            bucket_setup_template_gluster;
        fi
    fi
    if (( $fdtr > 0 )); then
        testDtr=$(lxc list $dtrName --format csv -c n)
        if [[ ! $testDtr ]]; then 
            bucket_setup_template_dtr;
        fi
    fi
    if (( $ftall > 0 )); then
        testClient=$(lxc list $initName --format csv -c n)
        if [[ ! $testClient ]]; then 
            bucket_setup_template_client;
        fi
        testNode=$(lxc list $nodeName --format csv -c n)
        if [[ ! $testNode ]]; then 
            bucket_setup_template_node;
        fi
        testMysql=$(lxc list $mysqlName --format csv -c n)
        if [[ ! $testMysql ]]; then 
            bucket_setup_template_mysql;
        fi
        testMssql=$(lxc list $mssqlName --format csv -c n)
        if [[ ! $testMssql ]]; then 
            bucket_setup_template_mssql;
        fi
        testK8s=$(lxc list $k8sName --format csv -c n)
        if [[ ! $testK8s ]]; then 
            bucket_setup_template_k8s;
        fi
        testGluster=$(lxc list $glusterName --format csv -c n)
        if [[ ! $testGluster ]]; then 
            bucket_setup_template_gluster;
        fi
        testDtr=$(lxc list $dtrName --format csv -c n)
        if [[ ! $testDtr ]]; then 
            bucket_setup_template_dtr;
        fi
        #bucket_setup_template_client;
        #bucket_setup_template_mysql;
        #bucket_setup_template_mssql;
        #bucket_setup_template_node;
        #bucket_setup_template_k8s;
        #bucket_setup_template_gluster;
        #bucket_setup_template_dtr;
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
        bucket_setup_template 0 0 0 0 0 0 0 1;
    fi
}