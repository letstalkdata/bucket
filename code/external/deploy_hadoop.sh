#!/bin/bash
#
ssh-keygen -f ~/.ssh/id_rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
ssh -o "StrictHostKeyChecking no" 127.0.0.1
ssh 127.0.0.1
#
wget -c http://apachemirror.wuchna.com/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
mkdir -p /opt/hadoop /opt/spark
tar -xvf hadoop-3.2.1.tar.gz --exclude=hadoop-3.2.1/share/doc
cp -r hadoop-3.2.1/* /opt/hadoop/
#
mkdir -p ~/hadoopdata/hdfs/{namenode,datanode}
#
yum -y install java-11-openjdk-devel
jloc="/usr/lib/jvm/"
jv=$(ls /usr/lib/jvm/ | grep java | grep openjdk-11 | xargs)
jloc=$jloc""$jv
#############
cat >>~/.bashrc<<EOF
export JAVA_HOME=$jloc   ## Change it according to your system
export HADOOP_HOME=/opt/hadoop   ## Change it according to your system
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_NODEMANAGER_USER=root
export YARN_RESOURCEMANAGER_USER=root
export HADOOP_INSTALL=/opt/hadoop
export HADOOP_MAPRED_HOME=/opt/hadoop
export HADOOP_COMMON_HOME=/opt/hadoop
export HADOOP_HDFS_HOME=/opt/hadoop
export YARN_HOME=/opt/hadoop
export HADOOP_YARN_HOME=/opt/hadoop
export HADOOP_COMMON_LIB_NATIVE_DIR=/opt/hadoop/lib/native
export PATH=$PATH:/opt/hadoop/sbin:/opt/hadoop/bin
EOF
source ~/.bashrc
####################################
truncate -s0 $HADOOP_HOME/etc/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
host=$(hostname)
echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n<configuration>\n    <property>\n        <name>fs.defaultFS</name>\n        <value>hdfs://$host:9000</value>\n    </property>\n</configuration>" | tee -a $HADOOP_HOME/etc/hadoop/core-site.xml
echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n<configuration>\n    <property>\n        <name>dfs.replication</name>\n        <value>1</value>\n    </property>\n    <property>\n        <name>dfs.name.dir</name>\n        <value>file:///root/hadoopdata/hdfs/namenode</value>\n    </property>\n    <property>\n        <name>dfs.data.dir</name>\n        <value>file:///root/hadoopdata/hdfs/datanode</value>\n    </property>\n</configuration>" | tee -a $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n<configuration>\n    <property>\n        <name>mapreduce.framework.name</name>\n        <value>yarn</value>\n    </property>\n</configuration>" | tee -a $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n<configuration>\n    <property>\n        <name>yarn.nodemanager.aux-services</name>\n        <value>mapreduce_shuffle</value>\n    </property>\n</configuration>" | tee -a $HADOOP_HOME/etc/hadoop/yarn-site.xml
hdfs namenode -format
start-dfs.sh