#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_create_dtr(){
    echo "Called Function **bucket_create_dtr**"
    nsName=$1
    shift
    nodeName=$1
    shift
    profile=$1
    #
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "default" ]]; then
        echo -e "${RED}Can not create local docker registry in [default] namespace. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Creating namespace.${NC}";
        echo $nsName >> db/ns.csv
        echo -e "${CYAN}New namespace ${GREEN}[$nsName]${CYAN} created successfully${NC}"   
    fi
    if [[ $nodeName == "default" ]]; then 
        echo -e "${RED}Cannot proceed without (--name) node name parameter. exiting...${NC}" ;
        exit 1;
    fi
    newDtrName="$nsName""-""$nodeName"
    echo $newDtrName
    check2=$(case $profile in tiny|mini|mini2|regular|regular2|heavy|heavy2|heavy3) echo yes;; *)  echo no;; esac)
    if [[ $check2 == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given profile. Valid bucket profiles are tiny, mini, mini2, regular, regular2, heavy, heavy2, heavy3${NC}" ;
        exit 1;
    fi
    lxc launch images:centos/7 $newDtrName --profile $profile
    sleep 5s
    cat preconfig/bootstrap-dtr.sh | lxc exec $newDtrName bash
}