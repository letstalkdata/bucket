yum -y install git
git clone https://github.com/elek/flokkr-runtime-kubernetes.git
docker pull flokkr/hadoop-hdfs-namenode:latest
docker pull flokkr/hadoop-hdfs-datanode:latest
