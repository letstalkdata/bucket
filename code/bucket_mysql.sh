#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_create_mysql() {
    # $namespace $profile $dbtype $sqlNode $dataNode $withClient
    nsName=$1
    shift
    profile=$1
    shift
    dbtype=$1
    shift
    sqlNode=$1
    shift
    dataNode=$1
    shift
    withClient=$1
    #
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "default" ]]; then
        echo -e "${RED}Can not create glusterFS cluster in [default] namespace. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Creating namespace.${NC}";
        echo $nsName >> db/ns.csv
        echo -e "${CYAN}New namespace ${GREEN}[$nsName]${CYAN} created successfully${NC}"   
    fi
    #
    profileCheck=$(case $profile in tiny|mini|mini2|regular|regular2|heavy|heavy2|heavy3) echo yes;; *)  echo no;; esac)
    if [[ $profileCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given profile. Valid bucket profiles are tiny, [mini], mini2, regular, regular2, heavy, heavy2, heavy3${NC}" ;
        exit 1;
    fi
    dbtypeCheck=$(case $dbtype in standalone|cluster) echo yes;; *)  echo no;; esac)
    if [[ $dbtypeCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given dbtype. Valid bucket profiles are standalone, cluster${NC}" ;
        exit 1;
    fi
    start=`date +%s`
    lxc file pull sys-dtr/certs/ca.crt configs/ca.crt
    clientName=$nsName"-client"
    if (( $withClient > 0 )); then
        echo -e "${CYAN}Deploying client node to access the mySQL cluster.${GREEN}[$clientName]${NC}"
        lxc copy sys-client-v1 $clientName --profile mini
        lxc start $clientName
        lxc file push configs/ca.crt $clientName/etc/docker/certs.d/sys-dtr:5000/ca.crt
    fi
    #
    singleMySQLNodeName=$nsName"-sql1"
    if [[ $dbtype == "standalone" ]]; then 
        lxc copy sys-mysql $singleMySQLNodeName --profile $profile
        lxc start $singleMySQLNodeName
        sleep 3s
        cat code/deploy-1N-mysql.sh | lxc exec $singleMySQLNodeName bash
        bucket_create_rope $singleMySQLNodeName "webssh"
    fi
    
}
