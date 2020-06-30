#!/bin/bash
#
# Setup GlusterFS repository
echo "[TASK 1] Setup GlusterFS repository"
yum -y -q install centos-release-gluster >/dev/null 2>&1
#
# Install gluster-server components
echo "[TASK 2] Install gluster-server components"
yum -y -q install glusterfs-server >/dev/null 2>&1
systemctl enable glusterd >/dev/null 2>&1
systemctl start glusterd >/dev/null 2>&1
systemctl status glusterd >/dev/null 2>&1
#
# Install additional required packages
echo "[TASK 3] Install additional packages"
yum install -y -q epel-release >/dev/null 2>&1
yum install -y -q wget which openssl shellinabox >/dev/null 2>&1
systemctl enable shellinaboxd.service >/dev/null 2>&1
systemctl start shellinaboxd.service
#
