#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
lxc launch images:centos/7 sys-k8s --profile mini2
sleep 5s
cat bootstrap-k8s.sh | lxc exec sys-k8s bash
lxc stop sys-k8s
#
echo -e "${CYAN} sys-dtr deployed successfully ${NC}"