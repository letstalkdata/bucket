#!/bin/bash
#
yum -y install python
yum -y install wget
wget https://repo.mysql.com//mysql80-community-release-el7-3.noarch.rpm
rpm -i mysql80-community-release-el7-3.noarch.rpm
yum -y update
yum -y install mysql-community-server mysql-shell
systemctl start mysqld.service
systemctl enable mysqld.service
systemctl status mysqld.service
temp_password=$(grep password /var/log/mysqld.log | awk '{print $NF}')

# https://lefred.be/content/mysql-innodb-cluster-mysql-shell-and-the-adminapi/
dba.configureInstance('mysql1',{clusterAdmin: 'newclusteradmin@%',clusterAdminPassword: 'Bucket1!sql'})