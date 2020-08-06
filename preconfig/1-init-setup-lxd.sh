#
sudo snap install lxd
sudo usermod -aG lxd $USER
newgrp lxd
sudo lxd --version
sudo lxd init --auto
#
sudo apt install -y net-tools
#
sudo apt install makedev
#

export BUCKET_HOME=/home/san/tools/own/bucket
export PATH=/home/san/tools/own/bucket:$PATH