#!/bin/bash
#
mkdir -p /root/mysqlrouter 
mysqlrouter --bootstrap 'root:Bucket1!sql'@localhost:3306 --directory /root/mysqlrouter --user=root >> /root/mysqlInit.log 2>&1
#cd /root/mysqlrouter
#./start.sh
#ps -ef | grep -i mysqlrou 
#netstat -tulnp | grep -i mysqlrouter 
