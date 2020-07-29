#!/bin/bash
#
mysqlsh 'root:<sqlcred>'@localhost:3306 -- dba create-cluster mysqlcluster >> /root/mysqlInit.log 2>&1
#
#mysqlsh 'root:<sqlcred>'@localhost:3306 -- cluster status 
