#!/bin/bash
#
#yum -y install mysql-shell mysql-router 
sed -i '/mysql/d' /etc/hosts 
rm -f /var/lib/mysql/auto.cnf 
systemctl restart mysqld 
mkdir -p /home/mysql/data
#
cat >>/root/mysql.conf<<EOF
[mysqld] 
datadir=/home/mysql/data/3306
log-error=/home/mysql/data/3306/my.error 
port=3306 
socket=/home/mysql/data/3306/my.sock 
mysqlx-port=33060 
mysqlx-socket=/home/mysql/data/3306/myx.sock 
log-bin=logbin 
relay-log=logrelay 
binlog-format=row 
binlog-checksum=NONE 
server-id=<srvid> 

# Enable gtid 
gtid-mode=on 
enforce-gtid-consistency=true 
log-save-updates=true 

# Table based repsitories 
master-info-repository=TABLE 
relay-log-info-repository=TABLE 

# Extraction Algorithm 
transaction-write-set-extraction=XXHASH64 
EOF
#
mysqlsh -- dba configure-instance { --port=3306 --host=localhost --password='<sqlcred>' --user=root } --mycnfPath='/root/mysql.conf' --interactive=false >> /root/mysqlInit.log 2>&1
systemctl restart mysqld 
mysqlsh -- dba check-instance-configuration { --port=3306 --host=localhost --password='<sqlcred>' --user=root } 