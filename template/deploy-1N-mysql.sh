#!/bin/bash
#
systemctl start mysqld.service
#systemctl status mysqld.service
# Get the temporary password
temp_password=$(grep password /var/log/mysqld.log | awk '{print $NF}')
# Set up a batch file with the SQL commands
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '<sqlcred>'; flush privileges;" > reset_pass.sql
# Log in to the server with the temporary password, and pass the SQL file to it.
mysql -u root --password="$temp_password" --connect-expired-password < reset_pass.sql >> /root/mysqlInit.log 2>&1
#
echo "create user 'root'@'%' identified by '<sqlcred>';" > remoteAccess.sql
echo "grant all privileges on *.* to 'root'@'%' with grant option;" >> remoteAccess.sql
echo "flush privileges;" >> remoteAccess.sql
echo "exit" >> remoteAccess.sql
#
pass="<sqlcred>"
mysql -u root --password="$pass" < remoteAccess.sql >> /root/mysqlInit.log 2>&1
#
#
echo "create user 'demo'@'%' identified by '<sqlcred>';" > remoteAccess.sql
echo "grant all privileges on *.* to 'demo'@'%' with grant option;" >> remoteAccess.sql
echo "flush privileges;" >> remoteAccess.sql
echo "exit" >> remoteAccess.sql
#
pass="<sqlcred>"
mysql -u root --password="$pass" < remoteAccess.sql >> /root/mysqlInit.log 2>&1
#