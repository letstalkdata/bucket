#!/bin/bash
#
kubectl create -f /root/1-influxdb.yaml >> /root/deployDashboard.log 2>&1
sleep 2s
kubectl create -f /root/2-heapster.yaml >> /root/deployDashboard.log 2>&1
sleep 2s
kubectl create -f /root/3-dashboard.yaml >> /root/deployDashboard.log 2>&1
sleep 2s
kubectl create -f /root/4-sa_cluster_admin.yaml >> /root/deployDashboard.log 2>&1
sleep 2s
#
tokn=$(kubectl -n kube-system describe sa dashboard-admin | grep Tokens | cut -d':' -f2 | xargs)
finalToken=$(kubectl -n kube-system describe secret $tokn | grep token: | cut -d':' -f2 | xargs)
echo $finalToken > /root/dashboard-token.txt
echo $finalToken