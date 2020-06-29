#!/bin/bash
#
# Setup GlusterFS repository
echo "[TASK 1] Setup GlusterFS repository"
yum -y -q install centos-release-gluster >/dev/null 2>&1
#
# Install gluster-server components
echo "[TASK 2] Install gluster-server components"
yum -y -q install glusterfs-server >/dev/null 2>&1
systemctl enable glusterd >/dev/null 2>&1
systemctl start glusterd >/dev/null 2>&1
systemctl status glusterd >/dev/null 2>&1
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
# Set Root password
echo "[TASK 4] Set root password"
echo "bucket" | passwd --stdin root >/dev/null 2>&1
#
# Install Openssh server
echo "[TASK 5] Install and configure ssh"
yum install -y -q openssh-server >/dev/null 2>&1
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl enable sshd >/dev/null 2>&1
systemctl start sshd >/dev/null 2>&1
# Install Openssh server
echo "[TASK 6] Install xfs utility"
yum install -y -q xfsprogs >/dev/null 2>&1
#