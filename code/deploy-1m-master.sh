#!/bin/bash
#
#######################################
# To be executed only on master nodes #
#######################################
k8sVersion="1.14.2"
#mknod /dev/kmsg c 1 11
# Initialize Kubernetes
#echo "[TASK 1] Initialize Kubernetes Cluster"
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all --kubernetes-version $k8sVersion >> /root/kubeinit.log 2>&1
#
# Copy Kube admin config
#echo "[TASK 2] Copy kube admin config to root user .kube directory"
mkdir /root/.kube > /dev/null 2>&1
cp /etc/kubernetes/admin.conf /root/.kube/config
#
# Deploy flannel network
#echo "[TASK 3] Deploy flannel network"
kubectl apply -f /root/kube-flannel.yml > /dev/null 2>&1
#
# Generate Cluster join command
#echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
joinCommand=$(kubeadm token create --print-join-command 2>/dev/null) 
echo "$joinCommand --ignore-preflight-errors=all" > /joincluster.sh