#!/bin/bash
clear; echo -e "\nRead comments/content in this file for details..."; sleep 2

# Host and system configurations. Replace hduser with your own username. This user must be "NON-ROOT" AND "NON-SUDO". Script will make it password-less sudo user.
myusername="hduser"; thishostname="master"; installdir="/opt"; sysrootpwd="hadoop"; myhadoopversion=3.0.0; hadoophome=/opt/hadoop; samplefilesdir=inputfiles

# MySQL config
mySQLHostName="localhost"; mySQLUserName="root"; mySQLUsrPwd="root"; mySQLDBName="metastore"; ooziedbname="ooziedb"; oozieusername="oozie"; oozieuserpwd="oozie"

# Hadoop config. This is for single node - only one master, salve for itself. Put as much as you want in this format - ("master" "master1" "master2").
myHadoopMasters=("master"); myHadoopSlaves=("master"); coresitehdfsport="9000"

# Java configuration
myjavaversion="1.8.0_131"; myJavaHome="$installdir/jdk$myjavaversion"; installedjava="$myJavaHome/bin/java"
#yum -y install java-1.8.0-openjdk
#jloc="/usr/lib/jvm/"
#jv=$(ls /usr/lib/jvm/ | grep java | xargs)
#jloc=$jloc""$jv"/jre"

# Check Input Files and Directory
if [[ ( ! -d $samplefilesdir ) || ( ! -e $samplefilesdir/1.txt) || ( ! -e $samplefilesdir/2.txt ) ]] ; then echo -e "\nSample files are missing...\nError...!!\n" ; exit -1; fi

CheckUser () {
    if [ $(whoami) == "root" ]; then echo -e "You MUST-NOT-BE-ROOT for this operation" ; exit -1; fi
    echo -e "Validating user..$myusername..."
    if [ ! -d /home/$myusername ] ; then echo -e "User does not exist\nError..!!" ; exit -1; else echo -e "User validation successful..." ; fi
}

FileOps () {
    command -v mysql >/dev/null 2>&1 || { echo -e "Error...\nMySQL is not installed or it is down\nCan not continue" >&2; exit 1; }
    echo -e "Downloading, extracting and copying files as needed..."; 
    sudo rm -rf $installdir/*; if [ -d ./extract ] ;then rm -rf ./extract/*; else mkdir extract; fi; if [ ! -d ./dwnld ] ; then mkdir dwnld; fi
    if [ ! -e ./dwnld/jdk-*.tar.gz ] ; then wget -P ./dwnld -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz; fi
    if [ ! -e ./dwnld/hadoop-*.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/hadoop/common/hadoop-3.0.0/hadoop-3.0.0.tar.gz; fi
    if [ ! -e ./dwnld/zookeeper-*.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/zookeeper/current/zookeeper-3.4.10.tar.gz; fi
    if [ ! -e ./dwnld/accumulo-*-bin.tar.gz ] ; then sudo wget -P ./dwnld http://apache.mirrors.lucidnetworks.net/accumulo/1.8.1/accumulo-1.8.1-bin.tar.gz; fi
    if [ ! -e ./dwnld/apache-hive-*-bin.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/hive/stable-2/apache-hive-2.3.2-bin.tar.gz; fi
    if [ ! -e ./dwnld/hbase-*-bin.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/hbase/2.0.0-alpha4/hbase-2.0.0-alpha4-bin.tar.gz; fi
    if [ ! -e ./dwnld/apache-flume-*-bin.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/flume/1.8.0/apache-flume-1.8.0-bin.tar.gz; fi
    if [ ! -e ./dwnld/spark-*-bin-hadoop2.7.tgz ] ; then sudo wget -P ./dwnld http://apache.claz.org/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz; fi
    if [ ! -e ./dwnld/sqoop-*-bin-hadoop200.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/sqoop/1.99.7/sqoop-1.99.7-bin-hadoop200.tar.gz; fi
    if [ ! -e ./dwnld/oozie-*.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/oozie/4.3.0/oozie-4.3.0.tar.gz; fi
    if [ ! -e ./dwnld/apache-tez-*-bin.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/tez/0.9.0/apache-tez-0.9.0-bin.tar.gz; fi
    if [ ! -e ./dwnld/solr-*.tgz ] ; then sudo wget -P ./dwnld http://apache.claz.org/lucene/solr/7.1.0/solr-7.1.0.tgz; fi
    if [ ! -e ./dwnld/kafka_*.tgz ] ; then sudo wget -P ./dwnld http://apache.claz.org/kafka/1.0.0/kafka_2.12-1.0.0.tgz; fi
    if [ ! -e ./dwnld/apache-storm-*.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/storm/apache-storm-1.1.1/apache-storm-1.1.1.tar.gz; fi
    if [ ! -e ./dwnld/pig-*.tar.gz ] ; then sudo wget -P ./dwnld http://apache.claz.org/pig/latest/pig-0.17.0.tar.gz; fi
    if [ ! -e ./dwnld/apache-maven-*-bin.tar.gz ] ; then sudo wget -P ./dwnld https://apache.claz.org/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz; fi
    if [ ! -e ./dwnld/mysql-connector-java-*.jar ] ; then sudo wget -P ./dwnld http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.44/mysql-connector-java-5.1.44.jar; fi
    if [ ! -e ./dwnld/ext-2.2.zip ] ; then sudo wget -P ./dwnld http://archive.cloudera.com/gplextras/misc/ext-2.2.zip; fi
    if [ ! -e ./dwnld/protobuf-2.6.1.tar.gz ] ; then sudo wget -P ./dwnld https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz; fi
    echo -e "Extracting files..."; for file in ./dwnld/*.{tar.gz,tgz}; do tar -zxf $file -C ./extract --warning=no-timestamp; done
    sudo chmod 777 -R ./*
    echo -e "Renaming directories..."; 
    mv ./extract/accumulo* ./extract/accumulo && 
    mv ./extract/apache-flume* ./extract/flume && 
    mv ./extract/apache-hive* ./extract/hive && 
    mv ./extract/apache-storm* ./extract/storm && 
    mv ./extract/apache-tez* ./extract/tez && 
    mv ./extract/hadoop* ./extract/hadoop && 
    mv ./extract/hbase* ./extract/hbase && 
    mv ./extract/kafka* ./extract/kafka && 
    mv ./extract/pig* ./extract/pig && 
    mv ./extract/solr* ./extract/solr && 
    mv ./extract/spark* ./extract/spark && 
    mv ./extract/sqoop* ./extract/sqoop && 
    mv ./extract/zookeeper* ./extract/zookeeper && 
    mv ./extract/apache-maven* ./extract/maven && 
    mv ./extract/protobuf* ./extract/protobuf
    echo -e "Copying directories to destination directory..."; 
    sudo cp -ralf ./extract/* $installdir; 
    echo -e "Making $myusername the owner of $installdir..."; 
    sudo chown -R $myusername $installdir; sudo cp ./dwnld/mysql-connector-java-5.1.44.jar $installdir/hive/lib
}

ConfigHADOOPEnv () {
    echo "Configuring...HDFS and YARN..."; 
    sudo truncate -s0 $installdir/hadoop/etc/hadoop/yarn-site.xml $installdir/hadoop/etc/hadoop/core-site.xml $installdir/hadoop/etc/hadoop/mapred-site.xml $installdir/hadoop/etc/hadoop/hdfs-site.xml
    echo -e "<?xml version=\"1.0\"?>\n<configuration>\n<property>\n<name>yarn.nodemanager.aux-services</name>\n<value>mapreduce_shuffle</value>\n</property>\n<property>\n<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\n<value>org.apache.hadoop.mapred.ShuffleHandler</value>\n</property>\n<property>\n<name>yarn.nodemanager.env-whitelist</name>\n<value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>\n</property>\n</configuration>" | sudo tee -a $installdir/hadoop/etc/hadoop/yarn-site.xml > /dev/null
    echo -e "<?xml version=\"1.0\"?>\n<configuration>\n<property>\n<name>fs.default.name</name>\n<value>hdfs://$thishostname:$coresitehdfsport/</value>\n</property>\n<property>\n<name>dfs.permissions</name>\n<value>false</value>\n</property>\n<property>\n<name>hadoop.proxyuser.$myusername.hosts</name>\n<value>*</value>\n</property>\n<property>\n<name>hadoop.proxyuser.$myusername.groups</name>\n<value>*</value>\n</property>\n</configuration>" | sudo tee -a $installdir/hadoop/etc/hadoop/core-site.xml > /dev/null
    echo -e "<?xml version=\"1.0\"?>\n<configuration>\n<property>\n<name>mapreduce.framework.name</name>\n<value>yarn</value>\n</property>\n<property>\n<name>yarn.nodemanager.vmem-check-enabled</name>\n<value>false</value>\n</property>\n<property>\n<name>yarn.nodemanager.vmem-pmem-ratio</name>\n<value>4</value>\n</property>\n<property>\n<name>yarn.app.mapreduce.am.env</name>\n<value>HADOOP_MAPRED_HOME=$installdir/hadoop</value>\n</property>\n<property>\n<name>mapreduce.map.env</name>\n<value>HADOOP_MAPRED_HOME=$installdir/hadoop</value>\n</property>\n<property>\n<name>mapreduce.reduce.env</name>\n<value>HADOOP_MAPRED_HOME=$installdir/hadoop</value>\n</property>\n</configuration>" | sudo tee -a $installdir/hadoop/etc/hadoop/mapred-site.xml > /dev/null
    echo -e "<?xml version=\"1.0\"?>\n<configuration>\n<property>\n<name>dfs.data.dir</name>\n<value>$installdir/hadoop/hadoop/dfs/datanode</value>\n<final>true</final>\n</property>\n<property>\n<name>dfs.name.dir</name>\n<value>$installdir/hadoop/hadoop/dfs/namenode</value>\n<final>true</final>\n</property>\n<property>\n<name>dfs.replication</name>\n<value>1</value>\n</property>\n</configuration>" | sudo tee -a $installdir/hadoop/etc/hadoop/hdfs-site.xml > /dev/null

    sudo sed -i '/^export JAVA_HOME/d' $installdir/hadoop/etc/hadoop/hadoop-env.sh; 
    echo -e "export JAVA_HOME=$myJavaHome" | sudo tee -a $installdir/hadoop/etc/hadoop/hadoop-env.sh &> /dev/null
    sudo mkdir -p $installdir/hadoop/hadoop/dfs/namenode; sudo mkdir -p $installdir/hadoop/hadoop/dfs/datanode; sudo mkdir -p $installdir/hadoop/etc/hadoop/conf
    sudo truncate -s0 $installdir/hadoop/etc/hadoop/masters $installdir/hadoop/etc/hadoop/slaves
    for ((i=0; i<${#myHadoopMasters[@]}; i++)) ; do mastername=${myHadoopMasters[i]} ; echo $mastername | sudo tee -a $installdir/hadoop/etc/hadoop/masters &> /dev/null; done
    for ((i=0; i<${#myHadoopSlaves[@]}; i++)) ; do slavename=${myHadoopSlaves[i]} ; echo $slavename | sudo tee -a $installdir/hadoop/etc/hadoop/slaves &> /dev/null; done; sleep 2
    echo "Configuring...Zookeeper..."; sudo truncate -s0 $installdir/zookeeper/conf/zoo.cfg
    echo -e "tickTime=2000\nsyncLimit=5\ndataDir=$installdir/zookeeper/data/\nclientPort=2181" | sudo tee -a $installdir/zookeeper/conf/zoo.cfg  &> /dev/null
    #\nserver.1=master:2888:3888\nserver.2=Slave1:2888:3888\nserver.3=Slave2:2888:3888
    if [ ! -d $installdir/zookeeper/data ] ; then sudo mkdir -p $installdir/zookeeper/data; fi
    sudo truncate -s0 $installdir/zookeeper/data/myid; echo -e "1" | sudo tee -a $installdir/zookeeper/data/myid &> /dev/null; sleep 2

    echo "Configuring...Hive..."; sudo cp $installdir/hive/conf/hive-default.xml.template $installdir/hive/conf/hive-default.xml; sudo truncate -s0 $installdir/hive/conf/hive-site.xml
    echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n<configuration>\n<property>\n<name>javax.jdo.option.ConnectionURL</name>\n<value>jdbc:mysql://$mySQLHostName/$mySQLDBName?createDatabaseIfNotExist=true</value>\n</property>\n<property>\n<name>hive.metastore.warehouse.dir</name>\n<value>/$myusername/hive/warehouse</value>\n</property>\n<property>\n<name>javax.jdo.option.ConnectionDriverName</name>\n<value>com.mysql.jdbc.Driver</value>\n</property>\n<property>\n<name>javax.jdo.option.ConnectionUserName</name>\n<value>$mySQLUserName</value>\n</property>\n<property>\n<name>javax.jdo.option.ConnectionPassword</name>\n<value>$mySQLUsrPwd</value>\n</property>\n</configuration>" | sudo tee -a $installdir/hive/conf/hive-site.xml &> /dev/null
    sudo cp $installdir/hive/conf/hive-env.sh.template $installdir/hive/conf/hive-env.sh; sudo truncate -s0 $installdir/hive/conf/hive-env.sh
    echo -e "HADOOP_HOME=$installdir/hadoop\nexport HADOOP_HEAPSIZE=512\nexport HIVE_CONF_DIR=$installdir/hive/conf" | sudo tee -a $installdir/hive/conf/hive-env.sh &> /dev/null
    mysql -u$mySQLUserName -p$mySQLUsrPwd  -e "create database $mySQLDBName" &> /dev/null 
    mysql --user="$mySQLUserName" --password="$mySQLUsrPwd" --database="$mySQLDBName" --execute="use $mySQLDBName; source $installdir/hive/scripts/metastore/upgrade/mysql/hive-schema-2.3.0.mysql.sql; source $installdir/hive/scripts/metastore/upgrade/mysql/hive-txn-schema-2.3.0.mysql.sql;create user root; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" &> /dev/null; sudo systemctl restart mariadb.service; sleep 2

    echo "Configuring...Hbase..."; sudo truncate -s0 $installdir/hbase/conf/hbase-site.xml
    echo -e "<?xml version=\"1.0\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n<configuration>\n<property>\n<name>hbase.rootdir</name>\n<value>hdfs://$thishostname:$coresitehdfsport/hbase</value>\n</property>\n<property>\n<name>hbase.cluster.distributed</name>\n<value>true</value>\n</property>\n<property>\n<name>hbase.zookeeper.property.clientPort</name>\n<value>2222</value>\n</property>\n<property>\n<name>hbase.zookeeper.property.dataDir</name>\n<value>$installdir/zookeeper/data</value>\n</property>\n</configuration>" | sudo tee -a $installdir/hbase/conf/hbase-site.xml &> /dev/null 
    sudo cp $installdir/hbase/conf/hbase-env.sh $installdir/hbase/conf/hbase-env.sh.bak; sudo sed -i '/^export JAVA_HOME/,$d' $installdir/hbase/conf/hbase-env.sh
    echo -e "export JAVA_HOME=$myJavaHome\nexport HBASE_REGIONSERVERS=\${HBASE_HOME}/conf/regionservers\nexport HBASE_MANAGES_ZK=true" | sudo tee -a $installdir/hbase/conf/hbase-env.sh &> /dev/null; sleep 2

    echo "Configuring...Storm..."; mkdir -p $installdir/storm/data; sudo sed -i '/^storm.zookeeper.servers/,$d' $installdir/storm/conf/storm.yaml
    echo -e "\nstorm.zookeeper.servers:\n - \"$thishostname\"\nstorm.local.dir: \"$installdir/storm/data\"\nnimbus.host: \"$thishostname\"\nsupervisor.slots.ports:\n - 6700\n - 6701\n - 6702\n - 6703" | sudo tee -a $installdir/storm/conf/storm.yaml &> /dev/null; sudo sed -i '/^export JAVA_HOME/,$d' $installdir/storm/conf/storm-env.sh
    echo -e "export JAVA_HOME=$myJavaHome\nexport STORM_CONF_DIR=$installdir/storm/data" | sudo tee -a $installdir/storm/conf/storm-env.sh &> /dev/null; sleep 2

    echo "Configuring...Sqoop..."; cp $installdir/sqoop/conf/sqoop.properties $installdir/sqoop/conf/sqoop.properties.bak; sudo sed -i '/^org.apache.sqoop.submission.engine.mapreduce.configuration.directory/d' $installdir/sqoop/conf/sqoop.properties; sudo sed -i '/^# Hadoop configuration directory/a org.apache.sqoop.submission.engine.mapreduce.configuration.directory='$installdir'/hadoop/etc/hadoop/' $installdir/sqoop/conf/sqoop.properties; sleep 2

    echo "Configuring...Flume..."; sudo cp $installdir/flume/conf/flume-env.sh.template $installdir/flume/conf/flume-env.sh; sudo cp $installdir/flume/conf/flume-conf.properties.template $installdir/flume/conf/flume-conf.properties; sudo truncate -s0 $installdir/flume/conf/flume-env.sh; echo -e "\nexport JAVA_HOME=$myJavaHome\nexport JAVA_OPTS=\"-Xms100m -Xmx2000m -Dcom.sun.management.jmxremote\"\nexport JAVA_OPTS=\"\$JAVA_OPTS -Dorg.apache.flume.log.rawdata=true -Dorg.apache.flume.log.printconfig=true\"" | sudo tee -a $installdir/flume/conf/flume-env.sh &> /dev/null; sudo truncate -s0 $installdir/flume/conf/flume-conf.properties
    echo -e "\nagent1.sources = tailAccessSource tailErrorSource\nagent1.sinks = hdfsSink\nagent1.channels = memChannel01\nagent1.sources.tailAccessSource.channels = memChannel01\nagent1.sources.tailErrorSource.channels = memChannel01\nagent1.sinks.hdfsSink.channel = memChannel01\nagent1.sources.tailAccessSource.type = exec\nagent1.sources.tailAccessSource.command = tail -F $HOME/Desktop/main/1.txt\nagent1.sources.tailErrorSource.type = exec\nagent1.sources.tailErrorSource.command = tail -F $HOME/Desktop/main/1.txt\nagent1.channels.memChannel01.type = memory\nagent1.channels.memChannel01.capacity = 100000\nagent1.channels.memChannel01.transactionCapacity = 10000\nagent1.sinks.hdfsSink.type = hdfs\nagent1.sinks.hdfsSink.hdfs.path = hdfs://$thishostname:9000/flume/data-example.1/\nagent1.sinks.hdfssink.hdfs.filetype = DataStream\nagent1.sinks.hdfsSink.hdfs.rollCount = 0\nagent1.sinks.hdfsSink.hdfs.rollSize = 0\nagent1.sinks.hdfsSink.hdfs.rollInterval = 60" | sudo tee -a $installdir/flume/conf/flume-conf.properties  &> /dev/null; sleep 2

    echo "Configuring...Accumulo..."; sudo cp $installdir/accumulo/conf/examples/512MB/standalone/* $installdir/accumulo/conf/
    sudo cp $installdir/accumulo/conf/accumulo-site.xml $installdir/accumulo/conf/accumulo-site.xml.bak; sudo cp $installdir/accumulo/conf/accumulo.policy.example $installdir/accumulo/conf/accumulo.policy; sudo sed -i '/<value>secret<\/value>/c\<value>'$sysrootpwd'<\/value>' $installdir/accumulo/conf/accumulo-site.xml
    sudo sed -i '/<value><\/value>/c\<value>hdfs://'$thishostname':'$coresitehdfsport'/accumulo<\/value>' $installdir/accumulo/conf/accumulo-site.xml     
    sudo sed -i '/# export ACCUMULO_MONITOR_BIND_ALL="true"/c\export ACCUMULO_MONITOR_BIND_ALL="true"' $installdir/accumulo/conf/accumulo-env.sh
    sudo sed -i '/&& export HADOOP_PREFIX=/c\   test -z "$HADOOP_PREFIX"      && export HADOOP_PREFIX='$installdir'/hadoop' $installdir/accumulo/conf/accumulo-env.sh
    sudo sed -i '/&& export JAVA_HOME=/c\       test -z "$JAVA_HOME"             && export JAVA_HOME='$myJavaHome'' $installdir/accumulo/conf/accumulo-env.sh
    sudo sed -i '/&& export ZOOKEEPER_HOME=/c\       test -z "$ZOOKEEPER_HOME"        && export ZOOKEEPER_HOME='$installdir'/zookeeper' $installdir/accumulo/conf/accumulo-env.sh; sleep 2

    echo "Configuring...Kafka..."; sudo mkdir -p $installdir/kafka/kafka-logs; sudo mkdir -p $installdir/kafka/tmp/kafka-logs-1; sudo mkdir -p $installdir/kafka/tmp/kafka-logs-2
    sudo cp $installdir/kafka/config/server.properties $installdir/kafka/config/server-one.properties; sudo cp $installdir/kafka/config/server.properties $installdir/kafka/config/server-two.properties
    sudo truncate -s0 $installdir/kafka/config/server-one.properties $installdir/kafka/config/server-two.properties
    sudo echo -e "broker.id=1\nport=9093\nnum.network.threads=3\nnum.io.threads=8\nsocket.send.buffer.bytes=102400\nsocket.receive.buffer.bytes=102400\nsocket.request.max.bytes=104857600\nlog.dirs=$installdir/kafka/tmp/kafka-logs-1\nnum.partitions=1\nnum.recovery.threads.per.data.dir=1\noffsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\ntransaction.state.log.min.isr=1\nlog.retention.hours=168\nlog.segment.bytes=1073741824\nlog.retention.check.interval.ms=300000\nzookeeper.connect=localhost:2181\nzookeeper.connection.timeout.ms=6000\ngroup.initial.rebalance.delay.ms=0" | sudo tee -a $installdir/kafka/config/server-one.properties  &> /dev/null
    sudo echo -e "broker.id=2\nport=9094\nnum.network.threads=3\nnum.io.threads=8\nsocket.send.buffer.bytes=102400\nsocket.receive.buffer.bytes=102400\nsocket.request.max.bytes=104857600\nlog.dirs=$installdir/kafka/tmp/kafka-logs-2\nnum.partitions=1\nnum.recovery.threads.per.data.dir=1\noffsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\ntransaction.state.log.min.isr=1\nlog.retention.hours=168\nlog.segment.bytes=1073741824\nlog.retention.check.interval.ms=300000\nzookeeper.connect=localhost:2181\nzookeeper.connection.timeout.ms=6000\ngroup.initial.rebalance.delay.ms=0" | sudo tee -a $installdir/kafka/config/server-two.properties  &> /dev/null; sleep 2

    echo "Configuring...Tez..."; sudo cp $installdir/tez/conf/tez-default-template.xml $installdir/tez/conf/tez-default.template; sudo cp $installdir/tez/conf/tez-default.template $installdir/tez/conf/tez-site.xml; sudo sed -i '/<value>hdfs:\/\/'$thishostname':'$coresitehdfsport'\/'$myusername'\/tez\/lib\/tez.tar.gz<\/value>/d' $installdir/tez/conf/tez-site.xml
    sudo sed -i '/<name>tez.lib.uris<\/name>/a<value>hdfs:\/\/'$thishostname':'$coresitehdfsport'/'$myusername'\/tez\/lib\/tez.tar.gz<\/value>' $installdir/tez/conf/tez-site.xml; sleep 2

}

ConfigOozie() {
    cd $installdir/oozie-4.3.0/
    source /home/$myusername/.bash_profile
    echo "Building oozie..."; sleep 3
    #mvn clean; mvn package -DskipTests -Phadoop-2 # -Dhadoop.version=2.7.3

    sudo chown $myusername -R $installdir
    source /home/$myusername/.bash_profile
    $installdir/oozie-4.3.0/bin/mkdistro.sh -DskipTests -Phadoop-2

    rm -rf $installdir/oozie
    rm -rf $installdir/oozie/libext

    mkdir $installdir/oozie
    mkdir $installdir/oozie/libext/

    echo "moving to oozie home..."; sleep 3
    cp -R $installdir/oozie-4.3.0/distro/target/oozie-4.3.0-distro/oozie-4.3.0/* $installdir/oozie
    echo "preparing libext..."; sleep 3
    cp $installdir/oozie-4.3.0/hadooplibs/hadoop-auth-2/target/oozie-hadoop-auth-hadoop*.jar $installdir/oozie/libext/
    cp $installdir/oozie-4.3.0/hadooplibs/hadoop-distcp-2/target/oozie-hadoop-distcp-hadoop*.jar $installdir/oozie/libext/
    cp $installdir/oozie-4.3.0/hadooplibs/hadoop-utils-2/target/oozie-hadoop-utils-hadoop*.jar $installdir/oozie/libext/
    cp /home/$myusername/Desktop/main/dwnld/ext-2.2.zip $installdir/oozie/libext/
    cp /home/$myusername/Desktop/main/dwnld/mysql-connector-java-5.1.44.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/**/*.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/common/*.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/common/lib/*.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/hdfs/lib/*.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/hdfs/*.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/mapreduce/*.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/mapreduce/lib/*.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/yarn/lib/*.jar $installdir/oozie/libext/
    cp $installdir/hadoop/share/hadoop/yarn/*.jar $installdir/oozie/libext/
    echo "Copying hadoop-config to oozie..."; sleep 3
    cp $installdir/hadoop/etc/hadoop/core-site.xml $installdir/oozie-4.3.0/distro/target/oozie-4.3.0-distro/oozie-4.3.0/conf/hadoop-conf/
    cp $installdir/hadoop/etc/hadoop/mapred-site.xml $installdir/oozie-4.3.0/distro/target/oozie-4.3.0-distro/oozie-4.3.0/conf/hadoop-conf/
    cp $installdir/hadoop/etc/hadoop/yarn-site.xml $installdir/oozie-4.3.0/distro/target/oozie-4.3.0-distro/oozie-4.3.0/conf/hadoop-conf/
    echo "Preparing war..."; sleep 3
    $installdir/oozie-4.3.0/distro/target/oozie-4.3.0-distro/oozie-4.3.0/bin/oozie-setup.sh prepare-war  &> /dev/null 
    cp $installdir/oozie-4.3.0/distro/target/oozie-4.3.0-distro/oozie-4.3.0/oozie.war $installdir/oozie/
    echo "Fixing war..."; sleep 3
    mkdir $installdir/oozie/warfilefix
    chown $myusername -R $installdir
    mv $installdir/oozie/oozie.war $installdir/oozie/warfilefix
    cd $installdir/oozie/warfilefix/
    jar xf oozie.war  &> /dev/null
    rm $installdir/oozie/warfilefix/WEB-INF/lib/hadoop*2.6.0.jar
    cd $installdir/oozie/warfilefix/
    echo "Making new war..."; sleep 3
    jar cf ../oozie.war ./*  &> /dev/null
    #rm -rf $installdir/oozie/warfilefix

    echo "Starting HDFS YARN and HistoryServer..."
    source $HOME/.bash_profile
    start-dfs.sh  &> /dev/null 
    start-yarn.sh  &> /dev/null 
    mr-jobhistory-daemon.sh start historyserver  &> /dev/null 

    echo "Oozie sharelib at Hadoop DFS..."
    $installdir/oozie/bin/oozie-setup.sh sharelib create -fs hdfs://$thishostname:$coresitehdfsport

    hdfs dfs -chown -R $myusername /

    echo "Working on OozieDB user..."; sleep 3
    mysql -u$mySQLUserName -p$mySQLUsrPwd  -e "create database $ooziedbname" &> /dev/null 
    mysql --user="$mySQLUserName" --password="$mySQLUsrPwd" --database="$ooziedbname" --execute="use $ooziedbname; CREATE USER '$oozieusername'@$thishostname'' IDENTIFIED BY '$oozieuserpwd' ; GRANT ALL PRIVILEGES ON $ooziedbname TO '$oozieusername'@'$thishostname' WITH GRANT OPTION; FLUSH PRIVILEGES;" &> /dev/null 
    sudo systemctl restart mariadb.service

    echo "Working on Oozie-Site.xml..."; sleep 3
    truncate -s0 $installdir/oozie/oozie-site.xml
    echo -e "<?xml version=\"1.0\"?>\n<configuration>\n<property> <name>oozie.service.ProxyUserService.proxyuser.hadoop.hosts</name> <value>*</value> </property>\n<property> <name>oozie.service.ProxyUserService.proxyuser.hadoop.groups</name> <value>*</value> </property>\n<property> <name>oozie.db.schema.name</name> <value>ooziedb</value> </property>\n<property> <name>oozie.service.JPAService.create.db.schema</name> <value>true</value> </property>\n<property> <name>oozie.service.JPAService.validate.db.connection</name> <value>true</value> </property>\n<property> <name>oozie.service.JPAService.jdbc.driver</name> <value>com.mysql.jdbc.Driver</value> </property>\n<property> <name>oozie.service.JPAService.jdbc.url</name> <value>jdbc:mysql://$thishostname/$ooziedbname</value> </property>\n<property> <name>oozie.service.JPAService.jdbc.username</name> <value>$oozieusername</value> </property>\n<property> <name>oozie.service.JPAService.jdbc.password</name> <value>$oozieuserpwd</value> </property>\n<property> <name>oozie.service.JPAService.pool.max.active.conn</name> <value>10</value> </property>\n<property> <name>oozie.service.HadoopAccessorService.hadoop.configurations</name> <value>*=$installdir/hadoop/etc/hadoop/</value></property>\n<property> <name>oozie.service.WorkflowAppService.system.libpath</name><value>hdfs:///user/$myusername/share/lib/lib_20170328132010</value></property>\n<property> <name>mapreduce.jobhistory.address</name> <value>$thishostname:10020</value> </property>\n</configuration>"  | tee -a $installdir/oozie/oozie-site.xml  &> /dev/null; sleep 2

    echo "copying mysql jar..."; sleep 3
    cp /home/$myusername/Desktop/main/dwnld/mysql-connector-java-5.1.44.jar $installdir/oozie/libext/


    echo "Creating oozie db..."; sleep 3
    $installdir/oozie/bin/oozie-setup.sh db create -run
    #mysql -uoozie -hnnode1 -poozie
    #mysql> use ooziedb;
    #mysql> show tables;

    echo "Starting oozie services..."; sleep 3
    $installdir/oozie/bin/oozied.sh start
    $installdir/oozie/bin/oozied.sh admin -status

    echo "Tar Oozie exmaples..."; sleep 3
    tar xfz $installdir/oozie/oozie-examples.tar.gz  -C $installdir/oozie/

    echo "Oozie exmaples to HDFS..."; sleep 3
    hadoop fs -put $installdir/oozie/examples /$myusername/oozie
    cp $installdir/oozie/examples/apps/map-reduce/job.properties $installdir/oozie/examples/apps/map-reduce/job.properties.bak
    truncate -s0 $installdir/oozie/examples/apps/map-reduce/job.properties

    echo -e "nameNode=hdfs://$thishostname:$coresitehdfsport\njobTracker=$thishostname:8032\nqueueName=default\nexamplesRoot=examples\noozie.use.system.libpath=true\noozie.wf.application.path=\${nameNode}/\${user.name}/oozie/\${examplesRoot}/apps/map-reduce" | tee -a $installdir/oozie/examples/apps/map-reduce/job.properties  &> /dev/null; sleep 2

    #$installdir/oozie/bin/oozie job -config $installdir/oozie/examples/apps/map-reduce/job.properties -run
    #oozie job -info 0000000-170328142601690-oozie-hado-W
    #$installdir/oozie/bin/oozie job -oozie http://$thishostname:11000/oozie -config $installdir/oozie/examples/apps/map-reduce/job.properties -run
    #$installdir/oozie/bin/oozie job -oozie http://$thishostname:11000/oozie -info 0000000-170408113318091-oozie-fars-W
    #$installdir/oozie/bin/oozie job -oozie http://$thishostname:11000/oozie -log 0000000-170408113318091-oozie-fars-W
    #$thishostname:19888
}

ConfigVerifyEnv () {
    echo "Setting Environment Variables..."; 
    sudo alternatives --install /usr/bin/java java $myJavaHome/bin/java 1; 
    sudo alternatives --install /usr/bin/jar jar $myJavaHome/bin/jar 1; 
    sudo alternatives --install /usr/bin/javac javac $myJavaHome/bin/javac 1; 
    sudo alternatives --set jar $myJavaHome/bin/jar; 
    sudo alternatives --set javac $myJavaHome/bin/javac; 
    sudo alternatives --set java $myJavaHome/bin/java; 
    sed -i '/^## JAVA/,$d' $HOME/.bash_profile
    echo -e "## JAVA env variables\n
    export JAVA_HOME=$myJavaHome/\n
    export PATH=\$PATH:\$JAVA_HOME/bin\n
    export MAVEN_HOME=$installdir/maven\n
    export CLASSPATH=.:\$JAVA_HOME/jre/lib:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar:$installdir/hbase/lib\n
    ## HADOOP env variables\n
    export HADOOP_HOME=$installdir/hadoop/\n
    export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop\n
    export SQOOP_HOME=$installdir/sqoop\n
    export PIG_HOME=$installdir/pig\n
    export SOLR_HOME=$installdir/solr\n
    export FLUME_HOME=$installdir/flume\n
    export PIG_CLASSPATH=\$HADOOP_CONF_DIR\n
    export ACCUMULO_HOME=$installdir/accumulo\n
    export ACCUMULO_CONF_DIR=\$ACCUMULO_HOME/conf\n
    export FLUME_CONF_DIR=$installdir/flume/conf\n
    export SPARK_HOME=$installdir/spark\n
    export HIVE_HOME=$installdir/hive\n
    export HCAT_HOME=\$HIVE_HOME/hcatalog\n
    export KAFKA_HOME=$installdir/kafka\n
    export TEZ_HOME=$installdir/tez\n
    export TEZ_CONF_DIR=\$TEZ_HOME/conf\n
    export TEZ_JARS=\$TEZ_HOME\n
    export STORM_HOME=$installdir/storm\n
    export OOZIE_HOME=$installdir/oozie\n
    export OOZIE_URL=http://$thishostname:11000/oozie\n
    export ZOOKEEPER_HOME=$installdir/zookeeper\n
    export HBASE_HOME=$installdir/hbase\n
    export HADOOP_COMMON_HOME=\$HADOOP_HOME\n
    export HADOOP_HDFS_HOME=\$HADOOP_HOME\n
    export HADOOP_MAPRED_HOME=\$HADOOP_HOME\n
    export HADOOP_YARN_HOME=\$HADOOP_HOME\n
    export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib/native\"\n
    export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native\n
    export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin:\$HIVE_HOME/bin:\$KAFKA_HOME/bin:\$HCAT_HOME/bin:\$SOLR_HOME/bin:\$STORM_HOME/bin:\$ZOOKEEPER_HOME/bin:\$SPARK_HOME/bin:\$HBASE_HOME/bin:\$OOZIE_HOME/bin:\$SQOOP_HOME/bin:\$FLUME_HOME/bin:\$PIG_HOME/bin:\$MAVEN_HOME/bin\n
    export OOZIE_VERSION=4.3.0
    if [ -z \$HIVE_AUX_JARS_PATH ]; then \n
        export HIVE_AUX_JARS_PATH=\$TEZ_JARS\nelse\n
        export HIVE_AUX_JARS_PATH=\$HIVE_AUX_JARS_PATH:\$TEZ_JARS\nfi\n
        export HADOOP_CLASSPATH=\${TEZ_CONF_DIR}:\${TEZ_JARS}/*:\${TEZ_JARS}/lib/*" >> $HOME/.bash_profile
    echo "Verifying Java-Version and HADOOP-HOME..."; source $HOME/.bash_profile
    if [[ "$installedjava" ]]; then version=$("$installedjava" -version 2>&1 | awk -F '"' '/version/ {print $2}');
    if [[ "$version" != $myjavaversion ]]; then echo -e "Error\nYour java-version is less than required - $version\nExiting now...." ;exit -1; break; fi; fi
    if [ ! -d $HADOOP_HOME ]; then echo -e "Missing HADOOP-HOME\nExiting now....Error..!!!" ;exit -1; break; fi
    echo -e "Configuring Dependencies..."
    sudo cp -R $HADOOP_HOME/share/hadoop/common/* $SQOOP_HOME/server/lib/; 
    sudo cp -R $HADOOP_HOME/share/hadoop/common/lib/* $SQOOP_HOME/server/lib/; 
    sudo cp -R $HADOOP_HOME/share/hadoop/hdfs/* $SQOOP_HOME/server/lib/; 
    sudo cp -R $HADOOP_HOME/share/hadoop/hdfs/lib/* $SQOOP_HOME/server/lib/; 
    sudo cp -R $HADOOP_HOME/share/hadoop/mapreduce/* $SQOOP_HOME/server/lib/; 
    sudo cp -R $HADOOP_HOME/share/hadoop/mapreduce/lib/* $SQOOP_HOME/server/lib/; 
    sudo cp -R $HADOOP_HOME/share/hadoop/mapreduce/lib/* $SQOOP_HOME/server/lib/; 
    sudo cp -R $HADOOP_HOME/share/hadoop/yarn/* $SQOOP_HOME/server/lib/; 
    sudo cp -R $HADOOP_HOME/share/hadoop/yarn/lib/* $SQOOP_HOME/server/lib/; 
    sudo rm $HIVE_HOME/lib/log4j-slf4j-impl*.jar; 
    sudo rm $TEZ_HOME/lib/slf4j-log4j12-1.*.jar
    sudo chown -R $myusername $installdir/*
}

ConfigSSH() {
    echo "Configuring Passwordless-SSH..."; rm -rf $HOME/.ssh/*; yes | ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -q -P ""; cp $HOME/.ssh/id_rsa.pub $HOME/.ssh/id_rsa_centos1.pub 
    echo "Making public keys as authorized..."; cat $HOME/.ssh/id_rsa_centos1.pub >> $HOME/.ssh/authorized_keys; echo "Setting-up SSH security on keys and folder..."
    chmod 640 $HOME/.ssh/authorized_keys && chmod 700 $HOME/.ssh/; ssh-add; sleep 2
}

InstallProtocolBuffer () {
    echo "Making and installing protocol buffer...it will take a while..."
    cd ./extract/protobuf/ && ./autogen.sh  &> /dev/null && ./configure  &> /dev/null && make  &> /dev/null && sudo make install  &> /dev/null && sudo ldconfig  &> /dev/null 
    cd ../../; echo "Protocol Buffer version..." && protoc --version; echo -e "Freeing up some space..."; rm -rf ./extract/*
}

HdfsAndYarnAction () {
    if [[ ( -d $installdir/hadoop/hadoop/dfs/namenode ) || ( -d $installdir/hadoop/hadoop/dfs/datanode) ]] ; then 
    sudo rm -rf $installdir/hadoop/hadoop/dfs/namenode $installdir/hadoop/hadoop/dfs/datanode; fi
    source $HOME/.bash_profile; echo "Formatting NAMENODE..."; sleep 5; hdfs namenode -format  &> /dev/null;
    echo "Starting HDFS YARN and HistoryServer..."
    source $HOME/.bash_profile; start-dfs.sh  &> /dev/null; start-yarn.sh  &> /dev/null; mr-jobhistory-daemon.sh start historyserver  &> /dev/null 
    echo "Creating directories in HDFS and setting permissions..."
    hdfs dfs -mkdir /$myusername; hdfs dfs -chown -R $myusername /; hdfs dfs -mkdir -p /$myusername/oozie; hdfs dfs -mkdir -p /$myusername/accumulo; hdfs dfs -mkdir -p /$myusername/hive/warehouse
    hdfs dfs -mkdir -p /$myusername/tez/lib; hdfs dfs -chmod g+w /$myusername/hive/warehouse; hdfs dfs -chmod g+w /tmp
    echo "Uploading files and libraries to HDFS..."
    hdfs dfs -put $installdir/hive/lib/hive-exec*.jar /$myusername/tez/lib; hdfs dfs -put $installdir/tez/share/tez.tar.gz /$myusername/tez/lib; 
    #hdfs dfs -put $installdir/tez/*.jar /$myusername/tez/lib #echo -e "hdfs dfs -copyFromLocal <localsrc> URI\n"
    hdfs dfs -put inputfiles/1.txt /$myusername; hdfs dfs -put inputfiles/2.txt /$myusername; hdfs dfs -chmod -R 777 /
    if [ ! -d /home/$myusername/Desktop/main ] ; then mkdir -p /home/$myusername/Desktop/main; fi
    hdfs dfs -get /$myusername/1.txt /home/$myusername/Desktop/main; hdfs dfs -get /$myusername/2.txt /home/$myusername/Desktop/main
    echo "Running map-reduce job (wordcount) on sample files..."
    # hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar  wordcount -Dwordcount.case.sensitive=true /hduser/1.txt /hduser/mrjoboutput/1
    yarn jar $hadoophome/share/hadoop/mapreduce/hadoop-mapreduce-examples-$myhadoopversion.jar  wordcount -Dwordcount.case.sensitive=true /$myusername/1.txt /$myusername/mrjoboutput/1
    yarn jar $hadoophome/share/hadoop/mapreduce/hadoop-mapreduce-examples-$myhadoopversion.jar  wordcount -Dwordcount.case.sensitive=true /$myusername/2.txt /$myusername/mrjoboutput/2
    echo "Running tez jobs (orderedwordcount) on sample files..."
    # hadoop jar /opt/tez/tez-examples*.jar orderedwordcount /hduser/1.txt /hduser/tezjoboutput/1
    yarn jar $TEZ_HOME/tez-examples*.jar orderedwordcount /$myusername/1.txt /$myusername/tezjoboutput/1
    yarn jar $TEZ_HOME/tez-examples*.jar orderedwordcount /$myusername/2.txt /$myusername/tezjoboutput/2
    echo "Getting output of map-reduce job (wordcount) on sample files..."
    #hadoop fs -cat /$myusername/mrjoboutput/1/part-r-*
    #hadoop fs -cat /$myusername/mrjoboutput/2/part-r-*
    #hadoop fs -cat /$myusername/tezjoboutput/1/part-r-*
    #hadoop fs -cat /$myusername/tezjoboutput/2/part-r-*
    echo "List all files and dirs under root folder of HDFS..."; hdfs dfs -ls /
    echo "List all files and dirs under a specific folder of HDFS..."; hdfs dfs -ls /$myusername/*
    echo "Verifying yarn nodes list..."; yarn node -list
    echo "Verifying HDFS status report..."; hdfs dfsadmin -report
    mr-jobhistory-daemon.sh stop historyserver; stop-yarn.sh; stop-dfs.sh
    echo -e "\n\nVerifying hadoop version ..."; hadoop version; echo "Configuring...Oozie..."; ConfigOozie; sleep 2
    echo -e "\nAll configurations successfully completed!!\n\n"
}

while true; do read -p "Do you wish to install this program (y/n)?" yn
case $yn in [Yy] )  clear; echo -e "Configuration started..."; CheckUser; FileOps; ConfigHADOOPEnv; ConfigVerifyEnv; ConfigSSH; InstallProtocolBuffer; HdfsAndYarnAction;
break;; 
[Nn]) echo -e "\nBye\n"; break;;
*) echo -e "Please answer y or n then press Enter"; esac; 
done
