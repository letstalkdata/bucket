#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
lxc launch images:centos/7 sys-dtr --profile mini
sleep 5s
cat bootstrap-dtr.sh | lxc exec sys-dtr bash
#
echo -e "${CYAN}sys-dtr deployed successfully ${NC}"