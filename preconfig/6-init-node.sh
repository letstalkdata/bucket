#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
lxc launch images:centos/7 sys-node --profile mini2
sleep 5s
cat $BUCKET_HOME/bootstrap-node.sh | lxc exec sys-node bash
lxc stop sys-node
#
echo -e "${CYAN} sys-node deployed successfully ${NC}"