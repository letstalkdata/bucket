#!/bin/bash
#
#######################################
# To be executed only on leader node  #
#######################################
#mknod /dev/kmsg c 1 11
# Initialize Kubernetes
echo "[TASK 1] Create kubeadm config"
mkdir -p /etc/kubernetes/kubeadm
cat >/etc/kubernetes/kubeadm/kubeadm-config.yaml<<EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.14.2
controlPlaneEndpoint: "10.6.230.88:6443"
networking:
  podSubnet: 10.244.0.0/16
EOF
# Initialize Kubernetes
echo "[TASK 2] Initialize Kubernetes leader"
kubeadm init \
    --config=/etc/kubernetes/kubeadm/kubeadm-config.yaml \
    --experimental-upload-certs \
	--ignore-preflight-errors=all >> /root/kubeinit.log 2>&1
#
# Copy Kube admin config
echo "[TASK 3] Copy kube admin config to root user .kube directory"
mkdir /root/.kube > /dev/null 2>&1
cp /etc/kubernetes/admin.conf /root/.kube/config
#
# Deploy flannel network
echo "[TASK 4] Deploy flannel network"
kubectl apply -f /root/kube-flannel.yml > /dev/null 2>&1
#
# Generate master join command
echo "[TASK 5] Generate and save master join command to /joinmasters.sh"
fnd="discovery-token-ca-cert-hash"
cat /root/kubeinit.log | grep $fnd -A 1 -B 1 -m 1 > /joinmasters.sh
truncate --size -1 /joinmasters.sh
echo " --ignore-preflight-errors=all >> /root/nodejoin.log 2>&1" >>/joinmasters.sh
sed  -i '1i mknod /dev/kmsg c 1 11 > /dev/null 2>&1' /joinmasters.sh
sed  -i '1i #' /joinmasters.sh
sed  -i '1i #!/bin/bash' /joinmasters.sh
#
# Generate worker join command
echo "[TASK 6] Generate and save worker join command to /joinworkers.sh"
workerjoinCommand=$(kubeadm token create --print-join-command 2>/dev/null) 
echo "$workerjoinCommand --ignore-preflight-errors=all" > /joinworkers.sh
truncate --size -1 /joinworkers.sh
echo " >> /root/nodejoin.log 2>&1" >>/joinworkers.sh
sed  -i '1i mknod /dev/kmsg c 1 11 > /dev/null 2>&1' /joinworkers.sh
sed  -i '1i #' /joinworkers.sh
sed  -i '1i #!/bin/bash' /joinworkers.sh