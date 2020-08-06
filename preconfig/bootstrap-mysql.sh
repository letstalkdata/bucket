#!/bin/bash
#
# Get the repo RPM and install it.
yum -y install wget
wget -i -c http://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
#
yum -y localinstall mysql80-community-release-el7-3.noarch.rpm
yum -y install mysql-community-server
#