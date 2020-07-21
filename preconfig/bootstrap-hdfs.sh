# lxc launch images:centos/7 sys-client-v1 --profile tiny
useradd bucket
echo "bucket" | passwd --stdin bucket >/dev/null 2>&1
yum -y install sudo
usermod -aG wheel bucket
su bucket
cd
wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
wget -c http://apachemirror.wuchna.com/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
wget -c https://mirrors.estointernet.in/apache/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz
mkdir -p /opt/java /opt/hadoop /opt/spark
cd dwnld
tar -xvf jdk-8u131-linux-x64.tar.gz 
tar -xvf hadoop-3.2.1.tar.gz --exclude=hadoop-3.2.1/share/doc
tar zxvf spark-3.0.0-bin-hadoop3.2.tgz
cp -r jdk1.8.0_131/* /opt/java/
cp -r spark-3.0.0-bin-hadoop3.2/* /opt/spark/
cp -r hadoop-3.2.1/* /opt/hadoop/
cat >>~/.bashrc<<EOF
# Hadoop related environment variable
export HADOOP_HOME=/opt/hadoop
#
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export HADOOP_MAPRED_HOME=/opt/hadoop
export HADOOP_COMMON_HOME=/opt/hadoop
export HADOOP_HDFS_HOME=/opt/hadoop
export YARN_HOME=/opt/hadoop
#
export JAVA_HOME=/opt/java
export PATH=/opt/hadoop/bin:$PATH
export PATH=/opt/hadoop/sbin:$PATH
export PATH=/opt/java/bin:$PATH
EOF
mkdir -p $HOME/hadoopdata/hdfs/{namenode,datanode}
