#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_create_client(){
    echo "Called Function **bucket_create_client**"
    nsName=$1
    shift
    clientName=$1
    #
    if [[ $nsName == "default" ]]; then
        echo -e "${RED}Cannot proceed without namespace parameter. exiting...${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Creating provided namespace.${NC}";
        echo $nsName >> db/ns.csv
        echo -e "${CYAN}New namespace ${GREEN}[$nsName]${CYAN} created Succesfully${NC}"   
    fi
    if [[ $clientName == "default" ]]; then 
        echo -e "${RED}Cannot proceed without (--name) client name parameter. exiting...${NC}" ;
        exit 1;
    fi
    newClientName="$nsName""-""$clientName"
    echo $newClientName
    lxc copy sys-client-v1 $newClientName
    lxc start $newClientName
    #
}