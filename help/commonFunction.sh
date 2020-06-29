#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
show_help_bucket(){
    echo -e "${CYAN}${GREEN}bucket${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${GREEN}bucket${CYAN} is an utility for building miniaturised version SQL Server Big Data Cluster${NC}"
    echo -e "${CYAN}for learning and validation purpose${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} [command]${NC}"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}config       Manage bucket instance and server configuration options${NC}"
    echo -e "${CYAN}cleanup      Cleanup Specified resources setup by bucket${NC}"
    echo -e "${CYAN}deploy       Deploy Specified resources using bucket${NC}"
    echo -e "${CYAN}info         Showcase overall information of bucket setup${NC}"
    echo -e "${CYAN}setup        Setup bucket environment on your ubuntu machine (physical/VM)${NC}"
    echo -e "${CYAN}show         Show instance and other running details${NC}"
    echo -e "${CYAN}snapshot     Manage bucket instance snapshots${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}-v  --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} [command] --help' for more information about a command.${NC}"
}

show_help_deploy(){
    echo -e "${CYAN}bucket deploy help"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy Specified resources using bucket"
    echo
    echo -e "${CYAN}Usage:"
    echo -e "${CYAN}bucket deploy [command]"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}registry       Manage local docker registry instance${NC}"
    echo -e "${CYAN}kubernetes     Manage kubernetes cluster instance${NC}"
    echo -e "${CYAN}bdc            Manage SQL Big Data Cluster instance${NC}"
    echo -e "${CYAN}auto           Deploy full SQL Big Data Cluster setup ${NC}"
    echo
    echo -e "${CYAN}Global Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}    --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} deploy [command] --help' for more information.${NC}"  
}

show_help_deploy_registry(){
    echo -e "${CYAN}bucket deploy registry help"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy local docker registry for the environment"
    echo
    echo -e "${CYAN}Usage:"
    echo -e "${CYAN}bucket deploy registry [command]"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}withbdcimage   Create local registry instance with all required SQL BDC Image${NC}"
    echo -e "${CYAN}nobdcimage     Create local registry instance with all required SQL BDC Image${NC}"
    echo -e "${CYAN}delete         Delete instance snapshots for given namespace${NC}"
    echo -e "${CYAN}show           List snapshots for given namespace${NC}"
    echo
    echo -e "${CYAN}Global Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}    --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} setup [command] --help' for more information.${NC}"  
}

show_help_deploy_kubernetes(){
    echo -e "${CYAN}bucket deploy kubernetes help"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy kubernetes cluster"
    echo
    echo -e "${CYAN}Usage:"
    echo -e "${CYAN}bucket deploy kubernetes [command]"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}fromscratch    Create local registry instance with all required SQL BDC Image${NC}"
    echo -e "${CYAN}fromtemplate   Create local registry instance with all required SQL BDC Image${NC}"
    echo -e "${CYAN}delete         Delete instance snapshots for given namespace${NC}"
    echo -e "${CYAN}show           List snapshots for given namespace${NC}"
    echo
    echo -e "${CYAN}Global Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}    --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} setup [command] --help' for more information.${NC}"  
}
show_help_snapshot(){
    echo -e "${CYAN}bucket snapshot help"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Manage snapshots of given namespace"
    echo
    echo -e "${CYAN}Usage:"
    echo -e "${CYAN}bucket snapshot [command]"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}create       Create instance snapshots for given namespace${NC}"
    echo -e "${CYAN}delete       Delete instance snapshots for given namespace${NC}"
    echo -e "${CYAN}restore      Restore snapshot to given namespace${NC}"
    echo -e "${CYAN}list         List snapshots for given namespace${NC}"
    echo
    echo -e "${CYAN}Global Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}    --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} [command] --help' for more information about a command.${NC}"
}

show_help_snapshot_create(){
    echo -e "${CYAN}bucket snapshot create help"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Create instance snapshot of given namespace"
    echo
    echo -e "${CYAN}Usage:"
    echo -e "${CYAN}bucket snapshot <namespace> <snapshot name> [flags]"
    echo
    echo -e "${CYAN}Example:"
    echo -e "${CYAN}bucket snapshot create "\""ns1"\"" "\""snap0"\""."
    echo
    echo -e "${CYAN}Flags:"
    echo -e "${CYAN}--no-expiry    Ignore any configured auto-expiry for the instance"
    echo -e "${CYAN}--stateful     Whether or not to snapshot the instance's running state"
    echo
    echo -e "${CYAN}Global Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}    --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} [command] --help' for more information about a command.${NC}"
}

show_help_snapshot_delete(){
    echo -e "${CYAN}bucket snapshot delete help"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Delete specified snapshot of given namespace"
    echo
    echo -e "${CYAN}Usage:"
    echo -e "${CYAN}bucket snapshot <namespace> <snapshot name>"
    echo
    echo -e "${CYAN}Example:"
    echo -e "${CYAN}bucket snapshot delete "\""ns1"\"" "\""snap0"\"
    echo
    echo -e "${CYAN}Global Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}    --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} [command] --help' for more information about a command.${NC}"
}

show_help_snapshot_restore(){
    echo -e "${CYAN}bucket snapshot restore help"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Restore specified snapshot of given namespace"
    echo
    echo -e "${CYAN}Usage:"
    echo -e "${CYAN}bucket snapshot restore <namespace> <snapshot name>"
    echo
    echo -e "${CYAN}Example:"
    echo -e "${CYAN}bucket snapshot delete "\""ns1"\"" "\""snap0"\"
    echo
    echo -e "${CYAN}Global Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}    --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} [command] --help' for more information about a command.${NC}"
}

show_help_snapshot_list(){
    echo -e "${CYAN}bucket snapshot list help"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}List all snapshots of given namespace"
    echo
    echo -e "${CYAN}Usage:"
    echo -e "${CYAN}bucket snapshot list"
    echo
    echo -e "${CYAN}Example:"
    echo -e "${CYAN}bucket snapshot list"
    echo
    echo -e "${CYAN}Global Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}    --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} [command] --help' for more information about a command.${NC}"
}

show_version(){
    echo -e "${GREEN}bucket${CYAN}    version v0.6${NC}"
    echo -e "${GREEN}lxc${CYAN}        version v3.21${NC}"
    echo -e "${GREEN}docker${CYAN}     version v19.03.5${NC}"
    echo -e "${GREEN}kubernetes${CYAN} version v1.17.1${NC}"
    echo -e "${GREEN}sqlbdc${CYAN}     version v2019-CU1${NC}"
}