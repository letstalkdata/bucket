#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
source config
#
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#cd $DIR
#
lxc launch images:centos/7 sys-client-v1 --profile tiny
sleep 5s
cat $BUCKET_HOME/preconfig/bootstrap-template.sh | lxc exec sys-client-v1 bash
sleep 2s
lxc file push $BUCKET_HOME/code/kube-flannel.yml sys-client-v1/root/kube-flannel.yml
cat $BUCKET_HOME/preconfig/bootstrap-client-v1.sh | lxc exec sys-client-v1 bash
sleep 2s
lxc stop sys-client-v1
echo -e "${CYAN}Client node template deployed successfully ${NC}"
#
lxc copy sys-client-v1 sys-k8s --profile mini2
lxc start sys-k8s
sleep 2s
cat $BUCKET_HOME/preconfig/bootstrap-k8s.sh | lxc exec sys-k8s bash
lxc stop sys-k8s
echo -e "${CYAN} sys-k8s deployed successfully ${NC}"
#
#: '
lxc copy sys-client-v1 sys-dtr --profile mini
lxc start sys-dtr
sleep 2s
lxc file push $BUCKET_HOME/images/flannel.tar.gz sys-dtr/root/flannel.tar.gz
cat $BUCKET_HOME/preconfig/bootstrap-dtr.sh | lxc exec sys-dtr bash

echo -e "${CYAN}sys-dtr deployed successfully ${NC}"
#
if [[ $withBDC == "yes" ]]; then 
    cat $BUCKET_HOME/preconfig/bdc-images.sh | lxc exec sys-dtr bash
fi
#'