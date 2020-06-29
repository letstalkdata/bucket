#!/bin/bash
#
# Install additional required packages
echo "[TASK 1] Install additional packages"
yum install -y python3 >/dev/null 2>&1
curl -o /root/epel-release-7-12.noarch.rpm  https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-12.noarch.rpm >/dev/null 2>&1
rpm -Uvh epel-release-7-12.noarch.rpm >/dev/null 2>&1
rpm --import https://packages.microsoft.com/keys/microsoft.asc >/dev/null 2>&1
curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2019.repo >/dev/null 2>&1
yum -y install lttng-ust >/dev/null 2>&1
yum -y install azdata-cli >/dev/null 2>&1
yum -y install centos-release-gluster >/dev/null 2>&1
yum install -y glusterfs-client >/dev/null 2>&1
#