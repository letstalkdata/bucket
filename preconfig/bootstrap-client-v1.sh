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
curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo >/dev/null 2>&1
yum -y install sudo >/dev/null 2>&1
yum makecache >/dev/null 2>&1
sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel >/dev/null 2>&1
echo 'export PATH=$PATH:/opt/mssql/bin:/opt/mssql-tools/bin' | sudo tee /etc/profile.d/mssql.sh 
source /etc/profile.d/mssql.sh 
#
echo "[TASK 2] Install MariaDB Client"
cat >/etc/yum.repos.d/MariaDB.repo<<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB >/dev/null 2>&1
yum -y install MariaDB-client MariaDB-shared >/dev/null 2>&1