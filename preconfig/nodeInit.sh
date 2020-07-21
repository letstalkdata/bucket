#!/bin/bash
#
yum install -y -q epel-release >> /nodeInit.log 2>&1
echo "bucket" | passwd --stdin root >> /nodeInit.log 2>&1
yum install -y -q openssh-server >> /nodeInit.log 2>&1
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
yum install -y -q openssl shellinabox >> /nodeInit.log 2>&1
systemctl enable shellinaboxd.service >> /nodeInit.log 2>&1
systemctl start shellinaboxd.service >> /nodeInit.log 2>&1
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