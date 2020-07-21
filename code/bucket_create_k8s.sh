#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
source code/bucket_rope.sh
source code/bucket_nfs.sh
#
bucket_create_k8s(){
    #$namespace $profile $k8sVersion $nMaster $nWorker $cni $csi $dtr $noClient
    nsName=$1
    shift
    profile=$1
    shift
    k8sVersion=$1
    shift
    nMaster=$1
    shift
    nWorker=$1
    shift
    cni=$1
    shift
    csi=$1
    shift
    dtr=$1
    shift
    noClient=$1
    #echo "nsName=$nsName profile=$profile k8sVersion=$k8sVersion nMaster=$nMaster nWorker=$nWorker cni=$cni csi=$csi dtr=$dtr noClient=$noClient"
    #
    #
    nodeTemplate="sys-client-v1"
    workerTemplate="sys-k8s"
    #
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "default" ]]; then
        echo -e "${RED}Can not create Kubernetes cluster in [default] namespace. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Creating namespace.${NC}";
        echo $nsName >> db/ns.csv
        echo -e "${CYAN}New namespace ${GREEN}[$nsName]${CYAN} created successfully${NC}"   
    fi
    profileCheck=$(case $profile in tiny|mini|mini2|regular|regular2|heavy|heavy2|heavy3) echo yes;; *)  echo no;; esac)
    if [[ $profileCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given profile. Valid bucket profiles are tiny, [mini], mini2, regular, regular2, heavy, heavy2, heavy3${NC}" ;
        exit 1;
    fi
    cniCheck=$(case $cni in flannel|Calico|Weave) echo yes;; *)  echo no;; esac)
    if [[ $cniCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given cni. Valid CNI options are [flannel], Calico and Weave${NC}" ;
        exit 1;
    fi
    dtrCheck=$(case $dtr in local|shared) echo yes;; *)  echo no;; esac)
    if [[ $dtrCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given dtr option. Valid dtr options are [shared] and Local.${NC}" ;
        exit 1;
    fi
    csiCheck=$(case $csi in local|nfs|gluster) echo yes;; *)  echo no;; esac)
    if [[ $csiCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given csi option. Valid dtr options are local, nfs and gluster.${NC}" ;
        exit 1;
    fi
    #
    masternode=$nsName"-kmaster1"
    existname=$(lxc list $masternode -c n --format csv | grep $masternode)
    if [ "$masternode" == "$existname" ]; then
        echo -e "${RED}Provided namespace alraedy have kubernetes nodes associted with it.${NC}" ;
        echo -e "${RED}Either delete all the K8s nodes in this namespace or provide another namespace to proceed.${NC}" ;
        echo -e "${RED}Exiting...${NC}" ;
        exit 1;
    fi
    ##### Check Master Nodes #####
    if [[ ! $nMaster ]]; then
        nMaster=1
        echo -e "${CYAN}Default is set to ${GREEN}[1]${CYAN} K8s master node${NC}"
    fi
    if (( $nMaster <= 0 )); then
        nMaster=1
        echo -e "${CYAN}Default is set to ${GREEN}[1]${CYAN} K8s master node${NC}"
    fi
    if (( $nMaster > 3 )); then
        echo -e "${BROWN}As of now we support maximum of ${GREEN}[3]${BROWN} master nodes only${NC}"
        read -p 'Do you want to continue with 3 master nodes setup? (y/n) [y]:' ac
        if [[ ! $ac ]]; then
            ac="n"
        fi
        if [ "$ac" == "n" ]; then
            echo -e "${RED}Exiting the setup...${NC}"
            exit 1
        fi
        nMaster=3
    fi
    ##### Check Worker Nodes #####
    if [[ ! $nWorker ]]; then
        nWorker=1
        echo -e "${CYAN}Default is set to ${GREEN}[1]${CYAN} K8s worker nodes${NC}"
    fi
    if (( $nWorker <= 0 )); then
        nWorker=1
        echo -e "${CYAN}Default is set to ${GREEN}[3]${CYAN} K8s worker nodes${NC}"
    fi
    if (( $nWorker > 9 )); then
        echo -e "${BROWN}As of now we support maximum of ${GREEN}[9]${BROWN} worker nodes only${NC}"
        read -p 'Do you want to continue with 9 worker nodes setup? (y/n) [y]:' bc
        if [[ ! $bc ]]; then
            bc="n"
        fi
        if [ "$bc" == "n" ]; then
            echo -e "${RED}Exiting the setup...${NC}"
            exit 1
        fi
        nWorker=9
    fi
    #
    start=`date +%s`
    finalmsg=""
    # Setup Client node
    lxc file pull sys-dtr/certs/ca.crt configs/ca.crt
    clientName=$nsName"-client"
    if (( $noClient < 1 )); then
        echo -e "${CYAN}Deploying client node to access the cluster.${GREEN}[$clientName]${NC}"
        lxc copy $nodeTemplate $clientName --profile mini
        lxc start $clientName
        lxc file push configs/ca.crt $clientName/etc/docker/certs.d/sys-dtr:5000/ca.crt
    fi
    # Setup Load balancer
    if (( $nMaster > 1 )); then
        lbname=$nsName"-k8slb"
        echo -e "${CYAN}Deploying K8s Loadbalancer node ${GREEN}[$lbname]${NC}"
        lxc copy $nodeTemplate $lbname --profile mini
        lxc start $lbname
        lxc file push configs/ca.crt $lbname/etc/docker/certs.d/sys-dtr:5000/ca.crt
    fi
    ## Deploy K8s master nodes 
    for (( c=1; c<=$nMaster; c++ ))
    do
        mname=$nsName"-kmaster"$c
        echo -e "${CYAN}Deploying K8s master node ${GREEN}[$mname]${NC}"
        lxc copy $workerTemplate $mname --profile mini
        lxc start $mname
        lxc file push configs/ca.crt $mname/etc/docker/certs.d/sys-dtr:5000/ca.crt
    done
    #
    # Deploy k8s worker Nodes
    for (( c=1; c<=$nWorker; c++ ))
    do
        wname=$nsName"-kworker"$c
        echo -e "${CYAN}Deploying K8s worker node ${GREEN}[$wname]${NC}"
        lxc copy $workerTemplate $wname --profile $profile
        lxc start $wname
        lxc file push configs/ca.crt $wname/etc/docker/certs.d/sys-dtr:5000/ca.crt
    done
    #
    #dur=$(( $(((($(date +%s)-$start)/60)) + 1 ))
    echo -e "${GREEN}Node Creation Duration: $((($(date +%s)-$start)/60)) minutes${NC}"
    #echo -e "${GREEN}Node Creation Duration: less than $dur minutes${NC}"
    # One Node K8s setup deployment
    if (( $nMaster == 1 )); then
        echo -e "${CYAN}Initializing K8s master nodes${NC}"
        lxc file push configs/ca.crt $masternode/etc/docker/certs.d/sys-dtr:5000/ca.crt
        cat code/deploy-1m-master.sh | lxc exec $masternode bash
        sleep 2s
        lxc file pull $masternode/joincluster.sh configs/join1mcluster.sh
        sed  -i '1i sleep 2s' configs/join1mcluster.sh
        sed  -i '1i mknod /dev/kmsg c 1 11 > /dev/null 2>&1' configs/join1mcluster.sh
        truncate --size -1 configs/join1mcluster.sh
        echo " > /dev/null 2>&1" >>configs/join1mcluster.sh
        #
        for (( c=1; c<=$nWorker; c++ )); do
            wname=$nsName"-kworker"$c
            echo -e "${CYAN}Joining worker node ${CYAN}[$wname] to the cluster${NC}"
            lxc file push configs/join1mcluster.sh $wname/joincluster.sh
            lxc file push configs/ca.crt $wname/etc/docker/certs.d/sys-dtr:5000/ca.crt
            lxc exec $wname bash /joincluster.sh &
        done
        lxc exec $masternode cat /etc/kubernetes/admin.conf > configs/k8s-admin.conf
        #cat configs/k8s-admin.conf > $HOME/.kube/config
        #lxc exec $clientName bash mkdir -p /root/.kube
        lxc file push configs/k8s-admin.conf $clientName/root/.kube/config
        rm -rf configs/join1mcluster.sh
        rm -rf configs/k8s-admin.conf
    fi
    #
    #############################################################
    #
    # Multi Node K8s setup deployment
    if (( $nMaster > 1 )); then
        lbname=$nsName"-k8slb"
        lbip=$(lxc list $lbname -c4 --format csv | grep eth0 | awk '{print $1}' | tr -d \")
        #echo "lbip=$lbip "
        echo -e "${CYAN}Configuring K8s Loadbalancer node ${GREEN}[$lbname]${NC}"
        echo "#!/bin/bash" > code/nginix-config.sh
        echo "#" > code/nginix-config.sh
        echo "mkdir -p /etc/nginx" >> code/nginix-config.sh
        echo "cat >>/etc/nginx/nginx.conf<<EOF" >> code/nginix-config.sh
        echo "events { }" >> code/nginix-config.sh
        echo "" >> code/nginix-config.sh
        echo "stream {" >> code/nginix-config.sh
        echo "    upstream stream_backend {" >> code/nginix-config.sh
        echo "        least_conn;" >> code/nginix-config.sh
        #echo "        server <node1>:6443 ;" >> code/nginix-config.sh
        #cat template/nginx-config.sh > code/deploy-nginx-lb.sh
        itr=1
        for (( c=1; c<=$nMaster; c++ )); do
            srv=""
            mname=$nsName"-kmaster"$c
            masterip=$(lxc list $mname -c4 --format csv | grep eth0 | awk '{print $1}'| tr -d \")
            srv="server $masterip:6443 ;"
            echo "        $srv" >> code/nginix-config.sh
            #find="<node$itr>"
            #sed -i -e "s/$find/$masterip/g" code/deploy-nginx-lb.sh
            itr=$((itr+1))
        done
        #
        echo "    }" >> code/nginix-config.sh
        echo "    server {" >> code/nginix-config.sh
        echo "        listen        6443 ;" >> code/nginix-config.sh
        echo "        proxy_pass    stream_backend ;" >> code/nginix-config.sh
        echo "        proxy_timeout 3s ;" >> code/nginix-config.sh
        echo "        proxy_connect_timeout 1s ;" >> code/nginix-config.sh
        echo "    }" >> code/nginix-config.sh
        echo "}" >> code/nginix-config.sh
        echo "EOF" >> code/nginix-config.sh
        echo "#" >> code/nginix-config.sh
        echo "docker pull nginx > /dev/null 2>&1" >> code/nginix-config.sh
        echo "#" >> code/nginix-config.sh
        echo "docker run --name proxy --restart=always -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -p 6443:6443 -d nginx > /dev/null 2>&1" >> code/nginix-config.sh
        echo "#" >> code/nginix-config.sh
        echo "sleep 3s" >> code/nginix-config.sh
        echo "#" >> code/nginix-config.sh
        echo "docker container ls" >> code/nginix-config.sh
        #
        cat code/nginix-config.sh | lxc exec $lbname bash 
        rm -rf code/deploy-nginx-lb.sh
        echo -e "${CYAN}Configuration of K8s Loadbalancer node ${GREEN}[$lbname]${CYAN} is ${GREEN}completed${NC}"
        #
        leader=$nsName"-kmaster1"
        k8sv="v1.14.2"
        certType="experimental-upload-certs"
        cat template/mm-leader-config.sh > code/deploy-mm-leader.sh
        sed -i -e "s/<k8s-version>/$k8sv/g" code/deploy-mm-leader.sh
        sed -i -e "s/<lbip>/$lbip/g" code/deploy-mm-leader.sh
        sed -i -e "s/<cert_type>/$certType/g" code/deploy-mm-leader.sh
        #
        echo -e "${CYAN}Configuring K8s leader ${GREEN}[$leader]${NC}"
        cat code/deploy-mm-leader.sh | lxc exec $leader bash
        #
        lxc exec $leader cat /etc/kubernetes/admin.conf > configs/k8s-admin.conf
        #cat configs/k8s-admin.conf > $HOME/.kube/config
        lxc file push configs/k8s-admin.conf $clientName/root/.kube/config
        rm -rf configs/k8s-admin.conf
        lxc file pull $leader/joinmasters.sh configs/joinmasters.sh
        lxc file pull $leader/joinworkers.sh configs/joinworkers.sh
        lxc file push configs/ca.crt $clientName/etc/docker/certs.d/sys-dtr:5000/ca.crt
        #
        for (( c=2; c<=$nMaster; c++ )); do
            mname=$nsName"-kmaster"$c
            echo -e "${CYAN}Joining master node ${CYAN}[$mname] to the cluster${NC}"
            lxc file push configs/joinmasters.sh $mname/joinmasters.sh
            lxc file push configs/ca.crt $mname/etc/docker/certs.d/sys-dtr:5000/ca.crt
            lxc exec $mname bash /joinmasters.sh &
        done
        #
        for (( c=1; c<=$nWorker; c++ )); do
            wname=$nsName"-kworker"$c
            echo -e "${CYAN}Joining worker node ${CYAN}[$wname] to the cluster${NC}"
            lxc file push configs/joinworkers.sh $wname/joinworkers.sh
            lxc file push configs/ca.crt $wname/etc/docker/certs.d/sys-dtr:5000/ca.crt
            lxc exec $wname bash /joinworkers.sh &
        done
    fi
    #
    echo -e "${GREEN}All node joined to K8s cluster...${NC}"
    bucket_create_rope $clientName "webssh"
    nfsName=$nsName"-nfs1"
    nfsIP=""
    if [[ $csi == "nfs" ]]; then
        echo -e "${CYAN}Deploying new NFS node [${GREEN}$nfsName${CYAN}]${NC}"
        bucket_create_nfs $nsName $profile > /dev/null 2>&1
        sleep 5s
        echo -e "${CYAN}configuring NFS dynamic storage provisioner${NC}"
        nfsIP=$(lxc list $nfsName -c4 --format csv | grep eth0 | awk '{print $1}' | tr -d \")
        lxc file push inside/nfsSC/default-sc.yaml $clientName/root/default-sc.yaml
        lxc file push inside/nfsSC/rbac.yaml $clientName/root/rbac.yaml
        cat inside/nfsSC/template/deployment.yaml > inside/nfsSC/deployment.yaml
        sed -i "s/<nfsIP>/$nfsIP/g" inside/nfsSC/deployment.yaml
        lxc file push inside/nfsSC/deployment.yaml $clientName/root/deployment.yaml
        lxc file push inside/nfsSC/setupNFS.sh $clientName/root/setupNFS.sh
        sleep 1s
        lxc exec $clientName bash /root/setupNFS.sh #> /dev/null 2>&1
        lxc file push examples/1-pvc-nfs.yaml $clientName/root/1-pvc-nfs.yaml 
        lxc file push examples/2-busybox-pv-nfs.yaml $clientName/root/2-busybox-pv-nfs.yaml 
    fi
    #
    echo -e "${GREEN}Deployment Duration: $((($(date +%s)-$start)/60)) minutes${NC}"
    #  
}
#
bucket_show_k8s(){
    nsName=$1
    lxc list $nsName
}