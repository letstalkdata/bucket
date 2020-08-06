#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
source $BUCKET_HOME/config
#
bucket_create_rope(){
    # $bucket $ropeType $hook
    bucket=$1
    shift
    ropeType=$1
    shift
    hook=$1
    #
    existname=$(lxc list $bucket -c n --format csv | grep $bucket)
    if [ "$bucket" != "$existname" ]; then
        echo -e "${RED}Provided Bucket Name does not exist{NC}" ;
        echo -e "${RED}Exiting...${NC}" ;
        exit 1;
    fi
    ropeCheck=$(case $ropeType in ssh|webssh|k8sui) echo yes;; *)  echo no;; esac)
    if [[ $ropeCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given rope type. Valid rope type options are ([ssh], webssh, k8sui) ${NC}" ;
        exit 1;
    fi
    #
    #ns=$(echo $bucket| cut -d'-' -f1)
    #
    cntr=$bucket
    if [[ $lxcSetup == "standalone" ]]; then 
        hostIP=$(ifconfig  eth0 | grep netmask | xargs | cut -d' ' -f2 | xargs)
    elif [[ $lxcSetup == "cluster" ]]; then 
        loc=$(lxc list $cntr -c L --format csv)
        hostIP=$(lxc cluster list --format csv | grep $loc | cut -d',' -f2 | cut -d':' -f2 | cut -d'/' -f3)
    fi
    curr=$(sort -nrk1,1 db/hooks.csv | head -1)
    nxt=$(( curr + 1 ))
    device="rope-"$ropeType"-"$nxt
    listen="tcp:0.0.0.0:"$nxt
    cntrIP=$(lxc list $cntr -c4 --format csv | grep eth0 | awk '{print $1}' | tr -d \")
    if [[ $ropeType == "ssh" ]]; then 
        hook="22"
    elif [[ $ropeType == "k8sui" ]]; then 
        hook="32323"
    elif [[ $ropeType == "webssh" ]]; then 
        hook="4200"
    fi
    connect="tcp:"$cntrIP":"$hook
    cmd="lxc config device add $cntr $device proxy listen=$listen connect=$connect"
    eval "$cmd" >/dev/null 2>&1
    echo
    echo $nxt >> db/hooks.csv
    msg="Bucket [$cntr] is connect with [$ropeType] rope type on [$hook] hook"
    echo -e "${GREEN}$msg${NC}"
    if [[ $ropeType == "ssh" ]]; then 
        echo -e "${GREEN}connect to the bucket from any machine in your LAN using SSH as: ${NC}" ;
        msg2="ssh root@"$hostIP" -p "$nxt
        echo -e "${GREEN}$msg2 ${NC}" ;
    elif [[ $ropeType == "k8sui" ]]; then 
        echo -e "${GREEN}connect to the kubernetes cluster dashboard from any machine in your LAN using below url: ${NC}" ;
        msg2="https://"$hostIP":"$nxt
        echo -e "${GREEN}$msg2 ${NC}" ;
    elif [[ $ropeType == "webssh" ]]; then 
        echo -e "${GREEN}connect to the bucket from web browser using below url: ${NC}" ;
        msg2="https://"$hostIP":"$nxt
        echo -e "${GREEN}$msg2 ${NC}" ;
    fi
}
#
bucket_delete_rope(){
    # $bucket $ropename
    bucket=$1
    shift
    ropeName=$1
    existname=$(lxc list $bucket -c n --format csv | grep $bucket)
    if [ "$bucket" != "$existname" ]; then
        echo -e "${RED}Provided Bucket Name does not exist{NC}" ;
        echo -e "${RED}Exiting...${NC}" ;
        exit 1;
    fi
    ropeCheck=$(lxc config device show $bucket | grep rope | cut -d':' -f1 | grep $ropeName)
    if [ "$ropeName" != "$ropeCheck" ]; then
        echo -e "${RED}Provided Rope Name does not exist on the bucket. available ropes on the bucket are:{NC}" ;
        echo "----------------------------------------"
        lxc config device show $bucket | grep rope | cut -d':' -f1
        echo "----------------------------------------"
        echo -e "${RED}Exiting...${NC}" ;
        exit 1;
    fi
    port=$(lxc config device show $bucket | grep rope | cut -d':' -f1 | cut -d'-' -f3)
    ropeType=$(lxc config device show $bucket | grep rope | cut -d':' -f1 | cut -d'-' -f2)
    lxc config device remove $bucket $ropeName
    sed -i "/$port/d" ./db/hooks.csv
    
} 
#
#bucket_show_rope(){
#    # $bucket
#    bucket=$1
#    existname=$(lxc list $bucket -c n --format csv | grep $bucket)
#    if [ "$bucket" != "$existname" ]; then
#        echo -e "${RED}Provided Bucket Name does not exist{NC}" ;
#        echo -e "${RED}Exiting...${NC}" ;
#        exit 1;
#    fi
#    lxc config device show $bucket | grep rope | cut -d':' -f1
#}  
