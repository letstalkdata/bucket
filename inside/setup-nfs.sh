#!/bin/bash
#
yum install -y -q nfs-utils > /dev/null 2>&1
mkdir -p /var/nfs/kubedata
chmod -R 755 /var/nfs/kubedata
chown nfsnobody:nfsnobody /var/nfs/kubedata 
systemctl enable rpcbind > /dev/null 2>&1
systemctl enable nfs-server > /dev/null 2>&1
systemctl enable nfs-lock > /dev/null 2>&1
systemctl enable nfs-idmap > /dev/null 2>&1
systemctl start rpcbind > /dev/null 2>&1
systemctl start nfs-server > /dev/null 2>&1
systemctl start nfs-lock > /dev/null 2>&1
systemctl start nfs-idmap > /dev/null 2>&1
# 
# Install additional required packages
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
echo "/var/nfs/kubedata    *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)" >> /etc/exports 
#
exportfs -rav > /dev/null 2>&1
exportfs -v > /dev/null 2>&1
systemctl restart nfs-server 
exportfs -v 