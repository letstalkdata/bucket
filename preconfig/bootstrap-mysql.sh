#!/bin/bash
#
# Get the repo RPM and install it.
echo "[TASK 1] Get MySQL release rpm"
yum -y install wget >/dev/null 2>&1
wget -i -c http://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm >/dev/null 2>&1
#
echo "[TASK 2] Installing MySQL "
yum -y localinstall mysql80-community-release-el7-3.noarch.rpm >/dev/null 2>&1
yum -y install mysql-community-server >/dev/null 2>&1
#