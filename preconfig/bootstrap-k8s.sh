#!/bin/bash
#
k8sVersion="1.14.2"
# Start and Enable kubelet service
echo "[TASK 1] Enable and start kubelet service"
systemctl enable kubelet >/dev/null 2>&1
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/sysconfig/kubelet
systemctl start kubelet >/dev/null 2>&1
#
# Pull k8s images in advance
echo "[TASK 2] Pull k8s images in advance"
kubeadm config images pull --kubernetes-version $k8sVersion >/dev/null 2>&1
#docker pull sys-dtr:5000/cni/flannel:v0.12.0-amd64
#