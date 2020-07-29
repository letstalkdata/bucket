#!/bin/bash
#
mysqlsh 'root:Bucket1!sql'@localhost:3306 -- dba create-cluster mysqlcluster >> /root/mysqlInit.log 2>&1
#
#mysqlsh 'root:Bucket1!sql'@localhost:3306 -- cluster status 
mysqlsh 'root:Bucket1!sql'@127.0.0.1:3306 -- cluster add-instance root@m2-mysql2 --password='Bucket1!sql' --recoveryMethod=clone ; >> /root/mysqlInit.log 2>&1
#

mysqlsh 'root:Bucket1!sql'@127.0.0.1:3306 -- cluster add-instance root@m2-mysql3 --password='Bucket1!sql' --recoveryMethod=clone ; >> /root/mysqlInit.log 2>&1
#

mysqlsh 'root:Bucket1!sql'@127.0.0.1:3306 -- cluster add-instance root@m2-mysql4 --password='Bucket1!sql' --recoveryMethod=clone ; >> /root/mysqlInit.log 2>&1
#

mysqlsh 'root:Bucket1!sql'@127.0.0.1:3306 -- cluster add-instance root@m2-mysql5 --password='Bucket1!sql' --recoveryMethod=clone ; >> /root/mysqlInit.log 2>&1
#

mysqlsh 'root:Bucket1!sql'@localhost:3306 -- cluster status 
