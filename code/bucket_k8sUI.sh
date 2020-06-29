#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
source code/bucket_rope.sh
#
bucket_create_k8sui(){
    echo "K8sUI dashboard deployment process started"
    # $bucket $ropeType $hook
    nsName=$1
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
        echo -e "${GREEN}Namespace doesnot exists. Exiting...${NC}";
        exit 1; 
    fi
    clientCNTR=$nsName"-client"
    masterCNTR=$nsName"-kmaster1"
    #
    lxc file push configs/1-influxdb.yaml $clientCNTR/root/1-influxdb.yaml
    lxc file push configs/2-heapster.yaml $clientCNTR/root/2-heapster.yaml
    lxc file push configs/3-dashboard.yaml $clientCNTR/root/3-dashboard.yaml
    lxc file push configs/4-sa_cluster_admin.yaml $clientCNTR/root/4-sa_cluster_admin.yaml
    lxc file push configs/deployUI.sh $clientCNTR/root/deployUI.sh
    #
    lxc exec $clientCNTR bash /root/deployUI.sh
    #
    bucket_create_rope $masterCNTR "k8sui"
}
bucket_show_k8sui(){
    nsName=$1
    #
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
        echo -e "${GREEN}Namespace doesnot exists. Exiting...${NC}";
        exit 1; 
    fi
    clientCNTR=$nsName"-client"
    masterCNTR=$nsName"-kmaster1"
    checkMaster=$(lxc list $masterCNTR -c n --format csv | grep $masterCNTR)
    if [ "$masterCNTR" != "$checkMaster" ]; then
        echo -e "${RED}Master node does not exists in provided namespace{NC}" ;
        echo -e "${RED}Exiting...${NC}" ;
        exit 1;
    fi
    rope=$(bucket_show_rope $masterCNTR)
    port=$(echo $rope | cut -d'-' -f3)
    #
    loc=$(lxc list $masterCNTR -c L --format csv)
    hostIP=$(lxc cluster list --format csv | grep $loc | cut -d',' -f2 | cut -d':' -f2 | cut -d'/' -f3)
    echo
    echo "-------Rope Name-------"
    echo "$rope"
    echo "-----------------------"
    echo
    echo "------------URL------------"
    msg1="https://"$hostIP":"$port
    echo $msg1
    echo "---------------------------"
    echo
    echo "------------Access Token-------------"
    echo
    lxc exec $clientCNTR cat /root/dashboard-token.txt
    echo
    echo "-------------------------------------"
}