#!/bin/bash
#
echo "[TASK 1] Set MSSQL Repo"
yum -y install sudo >/dev/null 2>&1
curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2019.repo >/dev/null 2>&1
curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo >/dev/null 2>&1
yum makecache >/dev/null 2>&1
echo "[TASK 2] Install MSSQL Client and server"
sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel >/dev/null 2>&1
yum install -y mssql-server 
echo 'export PATH=$PATH:/opt/mssql/bin:/opt/mssql-tools/bin' | sudo tee /etc/profile.d/mssql.sh >/dev/null 2>&1
source /etc/profile.d/mssql.sh >/dev/null 2>&1