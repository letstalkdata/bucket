#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_show_profile(){
    profile=$1
    #
    chkprofile=$(cat db/profile  | column -t -s "|" | grep $prf)
    if [[ ! $chkprofile ]]; then 
        echo -e "${GREEN}Provided profile name does not exist... Exiting...${NC}" ;
        exit 0;
    fi
    lxc profile show $profile
}
bucket_show_rope(){
    # $bucket
    bucket=$1
    existname=$(lxc list $bucket -c n --format csv | grep $bucket)
    if [ "$bucket" != "$existname" ]; then
        echo -e "${RED}Provided Bucket Name does not exist{NC}" ;
        echo -e "${RED}Exiting...${NC}" ;
        exit 1;
    fi
    lxc config device show $bucket | grep rope | cut -d':' -f1
}  