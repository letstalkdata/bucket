#!/bin/bash
#
TIMEOUT=60
RETRY_INTERVAL=3
echo "Verifying that the cluster is ready for deploying NFS CSI..."
totalNodes=$(kubectl get nodes --no-headers=true | awk '{print $2}' | wc -l | xargs)
while true ; do
    if [[ "$TIMEOUT" -le 0 ]]; then
        echo "Cluster node failed to reach the 'Ready' state. Kubeadm setup failed."
        exit 1
    fi
    readyNodes=$(kubectl get nodes --no-headers=true | grep Ready | awk '{print $2}' | wc -l | xargs)
    if [ "$totalNodes" == "$readyNodes" ]; then
        echo "All nodes are Ready."
        break
    fi
    sleep "$RETRY_INTERVAL"
    TIMEOUT=$(($TIMEOUT-$RETRY_INTERVAL))
    echo -n "."
done
#
kubectl create -f /root/rbac.yaml > /dev/null 2>&1
kubectl create -f /root/default-sc.yaml > /dev/null 2>&1
kubectl create -f /root/deployment.yaml > /dev/null 2>&1
#
echo "Waiting for NFS provisionar to be ready..."
nfsPod=$(kubectl get pods --no-headers=true | grep nfs | awk '{print $1}' | xargs)
while [[ $(kubectl get pod $nfsPod -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; 
do 
echo -n "." && sleep 2s; 
done
echo
kubectl get sc,pods
#
#totalNodes=$(kubectl get nodes --no-headers=true | awk '{print $2}' | wc -l | xargs)
#readyNodes=$(kubectl get nodes --no-headers=true | grep Ready | awk '{print $2}' | wc -l | xargs)
#until [ "$(kubectl get nodes --no-headers=true | grep Ready | awk '{print $2}' | wc -l | xargs)" == "$totalNodes" ]
#do
#  echo -n "."
#  sleep 1
#done
