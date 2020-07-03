#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_app_mssql() {
    # $mode $namespace $profile $deplType $sqlEdition $saCred $ha $replica $withClient
    mode=$1
    shift
    nsName=$1
    shift
    profile=$1
    shift
    deplType=$1
    shift
    sqlEdition=$1
    shift
    saCred=$1
    shift
    ha=$1
    shift
    replica=$1
    shift
    withClient=$1
    #
    modeCheck=$(case $mode in create|delete) echo yes;; *)  echo no;; esac)
    if [[ $modeCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given dbtype. Valid modes are [create], delete${NC}" ;
        exit 1;
    fi
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
    deplTypeCheck=$(case $deplType in node|docker|k8s) echo yes;; *)  echo no;; esac)
    if [[ $deplTypeCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given deplType. Valid deployment types are [node], docker and k8s${NC}" ;
        exit 1;
    fi
    sqlEditionCheck=$(case $sqlEdition in Developer|Evaluation|Express|Web|Standard|Enterprise) echo yes;; *)  echo no;; esac)
    if [[ $sqlEditionCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given SQL Server Edition. Valid editions are [Developer], Evaluation, Express, Web, Standard, Enterprise${NC}" ;
        exit 1;
    fi
    #
    #
    start=`date +%s`
    lxc file pull sys-dtr/certs/ca.crt configs/ca.crt
    clientName=$nsName"-client"
    if (( $withClient > 0 )); then
        echo -e "${CYAN}Deploying client node to access the msSQL cluster.${GREEN}[$clientName]${NC}"
        lxc copy sys-client-v1 $clientName --profile mini
        lxc start $clientName
        lxc file push configs/ca.crt $clientName/etc/docker/certs.d/sys-dtr:5000/ca.crt
    fi
    #
    primarySqlNode=$nsName"-mssql1"
    if (( $ha < 1 )); then
        if (( $replica > 0 )); then
            echo -e "${RED}Setting up MSSQL deployment without HA. Ignoring --replica parameter.${NC}" ;
        fi
        echo -e "${CYAN}Deploying Primary SQL Server node...${NC}" ;
        lxc copy sys-mssql $primarySqlNode --profile $profile
        lxc start $primarySqlNode
        sleep 3s
        echo -e "${CYAN}Setup and configure SQL Server Instance${NC}" ;
        cat template/deploy-1N-mssql.sh > code/deploy-1N-mssql.sh
        sed -i -e "s/<sacred>/$saCred/g" code/deploy-1N-mssql.sh
        sed -i -e "s/<sqledition>/$sqlEdition/g" code/deploy-1N-mssql.sh
        cat code/deploy-1N-mssql.sh | lxc exec $primarySqlNode bash
        if (( $withClient < 1 )); then
            echo -e "${CYAN}Setup wenssh rope to directly access SQL Server node${NC}" ;
            bucket_create_rope $primarySqlNode "webssh"
        fi
        echo -e "${GREEN}SQL Server Instance Deployment and configuration completed successfully${NC}" ;
        if (( $withClient > 0 )); then
            bucket_create_rope $clientName "webssh"
        fi
    elif (( $ha > 0 )); then
        if (( $replica < 1 )); then
            echo -e "${RED}Cannot proceed with given number of replica. Please pass appropriate --replica parameters${NC}" ;
            exit 1;
        fi
        echo "MSSQL HA deployment is not supported yet. Implementation is in progress.."
        exit 1;
    fi    
}