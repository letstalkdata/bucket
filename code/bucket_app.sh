#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_app_mssql() {
    # $namespace $profile $deplType $sqlEdition $saCred $ha $replica $withClient
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
    #
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "default" ]]; then
        echo -e "${RED}Can not create glusterFS cluster in [default] namespace. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat $BUCKET_HOME/db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Creating namespace.${NC}";
        echo $nsName >> $BUCKET_HOME/db/ns.csv
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
    lxc file pull sys-dtr/certs/ca.crt $BUCKET_HOME/configs/ca.crt
    clientName=$nsName"-client"
    if (( $withClient > 0 )); then
        echo -e "${CYAN}Deploying client node to access the MSSQL cluster.${GREEN}[$clientName]${NC}"
        lxc copy sys-client-v1 $clientName --profile mini
        lxc start $clientName
        lxc file push $BUCKET_HOME/configs/ca.crt $clientName/etc/docker/certs.d/sys-dtr:5000/ca.crt
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
        cat $BUCKET_HOME/template/deploy-1N-mssql.sh > $BUCKET_HOME/code/deploy-1N-mssql.sh
        sed -i -e "s/<sacred>/$saCred/g" $BUCKET_HOME/code/deploy-1N-mssql.sh
        sed -i -e "s/<sqledition>/$sqlEdition/g" $BUCKET_HOME/code/deploy-1N-mssql.sh
        cat $BUCKET_HOME/code/deploy-1N-mssql.sh | lxc exec $primarySqlNode bash
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
#
bucket_app_mysql() {
    # $namespace $profile $saCred $deplType $ha $haType $sqlNode $dataNode $replicaNode $withClient
    nsName=$1
    shift
    profile=$1
    shift
    saCred=$1
    shift
    deplType=$1
    shift
    ha=$1
    shift
    haType=$1
    shift
    sqlNode=$1
    shift
    dataNode=$1
    shift
    replicaNode=$1
    shift
    withClient=$1
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
    check=$(cat $BUCKET_HOME/db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Creating namespace.${NC}";
        echo $nsName >> $BUCKET_HOME/db/ns.csv
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
    #
    #
    start=`date +%s`
    lxc file pull sys-dtr/certs/ca.crt $BUCKET_HOME/configs/ca.crt
    clientName=$nsName"-client"
    if (( $withClient > 0 )); then
        echo -e "${CYAN}Deploying client node to access the MySQL cluster.${GREEN}[$clientName]${NC}"
        lxc copy sys-client-v1 $clientName --profile mini
        lxc start $clientName
        lxc file push $BUCKET_HOME/configs/ca.crt $clientName/etc/docker/certs.d/sys-dtr:5000/ca.crt
    fi
    #
    primarySqlNode=$nsName"-mysql1"
    if (( $ha < 1 )); then
        if (( $replicaNode > 0 )); then
            echo -e "${RED}Setting up MySQL deployment without HA. Ignoring --sqlNode, --dataNode and --replicaNode parameters.${NC}" ;
        fi
        echo -e "${CYAN}Deploying Primary MySQL node...${NC}" ;
        lxc copy sys-mysql $primarySqlNode --profile $profile
        lxc start $primarySqlNode
        sleep 3s
        echo -e "${CYAN}Setup and configure MySQL Instance${NC}" ;
        cat $BUCKET_HOME/template/deploy-1N-mysql.sh > $BUCKET_HOME/code/deploy-1N-mysql.sh
        sed -i -e "s/<sqlcred>/$saCred/g" $BUCKET_HOME/code/deploy-1N-mysql.sh
        cat $BUCKET_HOME/code/deploy-1N-mysql.sh | lxc exec $primarySqlNode bash
        if (( $withClient < 1 )); then
            echo -e "${CYAN}Setup wenssh rope to directly access MySQL Server node${NC}" ;
            bucket_create_rope $primarySqlNode "webssh"
        fi
        echo -e "${GREEN}MySQL Instance Deployment and configuration completed successfully${NC}" ;
        if (( $withClient > 0 )); then
            bucket_create_rope $clientName "webssh"
        fi
    elif (( $ha > 0 )); then
        if [[ $haType == "innodb" ]]; then
            if (( $replicaNode < 3 )); then
                echo -e "${RED}Cannot proceed with given number of replica. Please pass appropriate --replicaNode parameter${NC}" ;
                exit 1;
            fi
            echo "here.."
            for (( c=1; c<=$replicaNode; c++ ))
            do
                mysqlName=$nsName"-mysql"$c
                echo -e "${CYAN}Deploying MySQL Replical node ${GREEN}[$mysqlName]${NC}"
                lxc copy sys-mysql $mysqlName --profile $profile
                lxc start $mysqlName
            done
            echo -e "${CYAN}Setup and configure MySQL Instances${NC}" ;
            cat $BUCKET_HOME/template/deploy-1N-mysql.sh > $BUCKET_HOME/code/deploy-1N-mysql.sh
            sed -i -e "s/<sqlcred>/$saCred/g" $BUCKET_HOME/code/deploy-1N-mysql.sh
            serverID=101;
            for (( c=1; c<=$replicaNode; c++ ))
            do
                mysqlName=$nsName"-mysql"$c
                echo -e "${CYAN}Configuring MySQL Replical node ${GREEN}[$mysqlName]${NC}"
                cat $BUCKET_HOME/code/deploy-1N-mysql.sh | lxc exec $mysqlName bash
                sleep 2s
                cat $BUCKET_HOME/template/deploy-mm-mysql.sh > $BUCKET_HOME/code/deploy-mm-mysql.sh
                sed -i -e "s/<sqlcred>/$saCred/g" $BUCKET_HOME/code/deploy-mm-mysql.sh
                sed -i -e "s/<srvid>/$serverID/g" $BUCKET_HOME/code/deploy-mm-mysql.sh
                cat $BUCKET_HOME/code/deploy-mm-mysql.sh | lxc exec $mysqlName bash
                serverID=$((serverID+1))
            done
            echo -e "${CYAN}Deploying MySQL InnoDB cluster and adding replica nodes${NC}" ;
            cat $BUCKET_HOME/template/deploy-mm-mysql-cluster.sh > $BUCKET_HOME/code/deploy-mm-mysql-cluster.sh
            for (( c=2; c<=$replicaNode; c++ ))
            do
                mysqlName=$nsName"-mysql"$c
                echo "mysqlsh 'root:<sqlcred>'@127.0.0.1:3306 -- cluster add-instance root@$mysqlName --password='<sqlcred>' --recoveryMethod=clone ; >> /root/mysqlInit.log 2>&1" >> $BUCKET_HOME/code/deploy-mm-mysql-cluster.sh
                echo "#" >> $BUCKET_HOME/code/deploy-mm-mysql-cluster.sh
                echo "" >> $BUCKET_HOME/code/deploy-mm-mysql-cluster.sh
            done
            echo "mysqlsh 'root:<sqlcred>'@localhost:3306 -- cluster status " >> $BUCKET_HOME/code/deploy-mm-mysql-cluster.sh
            sed -i -e "s/<sqlcred>/$saCred/g" $BUCKET_HOME/code/deploy-mm-mysql-cluster.sh
            cat $BUCKET_HOME/code/deploy-mm-mysql-cluster.sh | lxc exec $primarySqlNode bash
            #
            echo -e "${CYAN}Deploying and configuring MySQL Router${NC}" ;
            cat $BUCKET_HOME/template/deploy-mysql-router.sh > $BUCKET_HOME/code/deploy-mysql-router.sh
            sed -i -e "s/<sqlcred>/$saCred/g" $BUCKET_HOME/code/deploy-mysql-router.sh
            for (( c=2; c<=$replicaNode; c++ ))
            do
                mysqlName=$nsName"-mysql"$c
                cat $BUCKET_HOME/code/deploy-mysql-router.sh | lxc exec $mysqlName bash
            done
            for (( c=2; c<=$replicaNode; c++ ))
            do
                mysqlName=$nsName"-mysql"$c
                lxc exec $mysqlName bash /root/mysqlrouter/start.sh &
            done
            echo -e "${GREEN}MySQL Cluster deployed successfully...${NC}"
        fi
    fi    
}