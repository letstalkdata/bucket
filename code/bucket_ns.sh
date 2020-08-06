#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_create_ns(){
    echo "Called Function **bucket_create_ns**"
    nsName=$1
    if [[ $nsName == "default" ]]; then 
        echo -e "${RED}default namespace is already present! Please provide an unique namespace name.${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat $BUCKET_HOME/db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo $nsName >> $BUCKET_HOME/db/ns.csv
        echo -e "${GREEN}Namespace${CYAN} $nsName${GREEN} has been created successfully.${NC}";
    else
        echo -e "${RED}Provided namespace name ${CYAN}$nsName${RED} is alraedy exists! kindly provide another name.${NC}"; 
        exit 1;
    fi
    #
    #created=$(date +%m-%d-%Y)"-"$(date +"%H-%M-%S")
}
#
bucket_delete_ns(){
    nsName=$1
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Can not be deleted. exiting...${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "default" ]]; then
        echo -e "${GREEN}[default] ${RED}namespace can not be deleted. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat $BUCKET_HOME/db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Nothing to do.${NC}";
        exit 0;
    fi
    bucket=$(lxc list $nsName --format csv -c n)
    if [[ ! $bucket ]]; then 
        sed -i "/$nsName/d" $BUCKET_HOME/db/ns.csv
        echo -e "${GREEN}namespace [$nsName] deleted successfully.${NC}" ;
        exit 0;
    fi
    echo -e "${RED}It will delete all buckets inside [$nsName] namespace${NC}" 
    echo -ne "${CYAN}"
    echo "$bucket"
    echo -ne "${NC}"
    read -p "Are you Sure want to continue? (y/n)?" choice
    case "$choice" in 
        y|Y ) 
            echo -e "${CYAN}Deleting namespace [$nsName]...${NC}"
            #lxc stop $(lxc list $nsName --format csv -c n)
            nfsNode=$(lxc list $nsName --format csv -c n | grep nfs | xargs)
            if [[ $nfsNode ]]; then 
                lxc stop -f $nfsNode
                lxc delete -f $nfsNode
            fi
            lxc list $nsName --format csv -c n | while read -r line ; do
                ldNo=$(lxc config device list $line | grep ldDisk | cut -d'-' -f2)
                lxc stop -f $line
                lxc delete -f $line
            done
            #lxc delete -f $(lxc list $nsName --format csv -c n)
            sed -i "/$nsName/d" $BUCKET_HOME/db/ns.csv
            echo -e "${GREEN}Namespace [$nsName] deleted successfully.${NC}"
            ;;
        n|N ) 
            echo -e "${CYAN}Delete aborted.${NC}"
            exit 1;
            ;;
        * ) 
            echo -e "${RED}Invalid input. Exiting...${NC}"
            exit 1;
            ;;
    esac
}
#
bucket_show_ns(){
    cat $BUCKET_HOME/db/ns.csv  | column -t -s "|"
}
