#!/bin/bash
#
# Setting up re-try option for joining masters
fnd="joined"
check=$(cat /root/nodejoin.log | grep $fnd)
if [[ ! $check ]]; then 
    sleep 20s
    sh /joinmasters.sh
fi