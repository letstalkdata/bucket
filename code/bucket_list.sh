#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
#
bucket_list_node() {
    # $namespace
    nsName=$1
    #
    lxc list $nsName
}
