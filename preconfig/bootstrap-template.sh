#!/bin/bash
#
k8sVersion="1.17.1"
mkdir -p /root/.kube
# Install docker from Docker-ce repository
echo "[TASK 1] Install docker container engine"
yum install -y -q yum-utils device-mapper-persistent-data lvm2 > /dev/null 2>&1
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null 2>&1
yum install -y -q docker-ce-3:19* docker-ce-cli-1:19*>/dev/null 2>&1
#
# Enable docker service
echo "[TASK 2] Enable and start docker service"
systemctl enable docker >/dev/null 2>&1
systemctl start docker
#
#certLoc="/etc/docker/certs.d/sqldtr:5000"
mkdir -p /etc/docker/certs.d/sys-dtr:5000 #$certLoc

# Add yum repo file for Kubernetes
echo "[TASK 3] Add yum repo file for kubernetes"
cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
#
# Install Kubernetes
echo "[TASK 4] Install Kubernetes (kubeadm, kubelet and kubectl)"
yum install -y -q kubeadm-$k8sVersion kubelet-$k8sVersion kubectl-$k8sVersion >/dev/null 2>&1
#
# Install additional required packages
echo "[TASK 5] Install additional packages"
yum install -y -q epel-release  >/dev/null 2>&1
yum install -y nfs-utils net-tools >/dev/null 2>&1
yum install -y -q wget which openssl yum-versionlock sshpass shellinabox >/dev/null 2>&1
systemctl enable shellinaboxd.service >/dev/null 2>&1
systemctl start shellinaboxd.service
cat >>/etc/securetty<<EOF
pts/0
pts/1
Pts/2
Pts/3
Pts/4
Pts/5
Pts/6
Pts/7
Pts/8
Pts/9
EOF
#
echo "[TASK 6] lock software versions"
yum versionlock docker* >/dev/null 2>&1
yum versionlock kube* >/dev/null 2>&1
# Create volume for persistent storage
echo "[TASK 7] Create volume for local persistent storage"
export PV_COUNT="500"
for i in $(seq 1 $PV_COUNT); do
  vol="vol$i"
  mkdir -p /mnt/local-storage/$vol
  mount --bind /mnt/local-storage/$vol /mnt/local-storage/$vol
done
#
# Set Root password
echo "[TASK 8] Set root password"
echo "bucket" | passwd --stdin root >/dev/null 2>&1
#
# Install Openssh server
echo "[TASK 9] Install and configure ssh"
yum install -y -q openssh-server >/dev/null 2>&1
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl enable sshd >/dev/null 2>&1
systemctl start sshd >/dev/null 2>&1
#
# Hack required to provision K8s v1.15+ in LXC containers
mknod /dev/kmsg c 1 11
chmod +x /etc/rc.d/rc.local
echo 'mknod /dev/kmsg c 1 11' >> /etc/rc.d/rc.local
#
yum install -y -q xfsprogs >/dev/null 2>&1
