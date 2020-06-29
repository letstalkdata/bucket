#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
source code/bucket_create_node.sh
source code/bucket_rope.sh
#
bucket_create_nfs() {
    nsName=$1
    shift
    profile=$1
    #
    # # $namespace $nodecount $profile $os $osv $withClient $withVolume $volumeGB
    nodeName=$nsName"-node1"
    bucket_create_node $nsName 1 $profile centos 7 0 0 0
    newNodeName=$nsName"-nfs1"
    lxc stop $nodeName
    lxc rename $nodeName $newNodeName
    lxc start $newNodeName
    echo -e "${CYAN}Bucket created... setting up NFS.${NC}" ;
    #
    sleep 5s
    cat inside/setup-nfs.sh | lxc exec $newNodeName bash
    #
    echo -e "${GREEN}NFS Share bucket [$newNodeName] created succesfully.${NC}" ;
    #
    bucket_create_rope $newNodeName "webssh"
}

bucket_delete_nfs() {
    echo
}