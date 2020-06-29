#!/bin/bash
#
# Start and Enable kubelet service
echo "[TASK 1] Enable and start kubelet service"
systemctl enable kubelet >/dev/null 2>&1
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/sysconfig/kubelet
systemctl start kubelet >/dev/null 2>&1
#
#lock software versions
echo "[TASK 2] lock software versions"
yum versionlock docker*
yum versionlock kube*
#
# Install additional required packages
echo "[TASK 3] Install additional packages"
yum install -y -q epel-release >/dev/null 2>&1
yum install -y -q wget which openssl shellinabox >/dev/null 2>&1
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