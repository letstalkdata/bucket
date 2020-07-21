#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
#
bucket_exec_bash() {
    nodeName=$1
    #
    bucket=$(lxc list $nodeName --format csv -c n)
    if [[ ! $bucket ]]; then 
        echo -e "${GREEN}Provided Bucket node does not exist... Exiting...${NC}" ;
        exit 0;
    fi
    lxc exec $nodeName bash
}
#
bucket_exec_code() {
    # $$namespace $bucket $codePath $execType $onClient 
    nsName=$1
    shift
    bucket=$1
    shift
    codePath=$1
    shift
    execType=$1
    shift
    onClient=$1
    #
    isBucket=1;
    #
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
    if [[ $bucket == "default" ]]; then
        isBucket=0;
    fi
    bucketname=$(lxc list $bucket -c n --format csv | grep $bucket)
    if (( $isBucket == 1 )); then
        if [ "$bucket" != "$bucketname" ]; then
            echo "Node Name = $bucket"
            echo -e "${RED}Provided Bucket Name does not exist{NC}" ;
            echo -e "${RED}Exiting...${NC}" ;
            exit 1;
        fi
    fi
    #
    if [[ $codePath == "default" ]]; then
        echo -e "${RED}Please provide Valid bash script name with location to proceed. Exiting...${NC}" ;
        exit 1;
    fi
    #file="/.config/backup.cfg"
    if [ ! -f "$codePath" ]
    then
        echo -e "${RED}$0: File '${codePath}' not found. Exiting...${NC}" 
        exit 1;
    fi
    #
    execTypeCheck=$(case $execType in s|p) echo yes;; *)  echo no;; esac)
    if [[ $execTypeCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given execution type. Valid exec types are [s]=serial, p=parallel ${NC}" ;
        exit 1;
    fi
    #
    #
    codeFileName="${codePath##*/}"
    if (( $isBucket == 1 )); then
        cat $codePath | lxc exec $bucket bash 
        echo -e "${CYAN}Code execution completed.${NC}"
    elif (( $isBucket == 0 )); then
        if [[ $execType == "s" ]]; then
            if (( $onClient == 0 )); then
                lxc list $nsName --format csv -c n | grep -v client | while read -r line ; do
                    cat $codePath | lxc exec $line bash 
                done
            elif (( $onClient == 1 )); then
                lxc list $nsName --format csv -c n | while read -r line ; do
                    cat $codePath | lxc exec $line bash 
                done
            fi
            echo -e "${CYAN}Code execution completed.${NC}"
        elif [[ $execType == "p" ]]; then
            if (( $onClient == 0 )); then
                lxc list $nsName --format csv -c n | grep -v client | while read -r line ; do
                    destPath=$line"/execParllel.sh"
                    lxc file push $codePath $destPath
                done
                lxc list $nsName --format csv -c n | grep -v client | while read -r line ; do
                    lxc exec $line bash /execParllel.sh & 
                done
            elif (( $onClient == 1 )); then
                lxc list $nsName --format csv -c n | while read -r line ; do
                    destPath=$line"/execParllel.sh"
                    lxc file push $codePath $destPath
                done
                lxc list $nsName --format csv -c n | while read -r line ; do
                    lxc exec $line bash /execParllel.sh & 
                done
            fi
            echo -e "${CYAN}Code execution scheduled in parallel.${NC}"
        fi
    fi
}

 