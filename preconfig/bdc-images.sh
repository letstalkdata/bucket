#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
# Pulling SQL Server Big Data Cluster images from Microsoft registry
echo -e "[TASK 1]${CYAN} Pulling SQL Server Big Data Cluster images from Microsoft registry...${NC}"
echo \
mcr.microsoft.com/mssql/bdc/mssql-app-service-proxy:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-control-watchdog:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-dns:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-mleap-serving-runtime:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-monitor-fluentbit:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-monitor-grafana:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-monitor-influxdb:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-monitor-kibana:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-monitor-telegraf:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-security-domainctl:2019-CU4-ubuntu-16.04 \
| xargs -P50 -n1 docker pull
echo
echo \
mcr.microsoft.com/mssql/bdc/mssql-security-knox:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-security-support:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-ha-operator:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-ha-supervisor:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-service-proxy:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-monitor-collectd:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-mlserver-py-runtime:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-server:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-server-controller:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-controller:2019-CU4-ubuntu-16.04 \
| xargs -P50 -n1 docker pull
echo
echo \
mcr.microsoft.com/mssql/bdc/mssql-server-data:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-hadoop:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-mlserver-r-runtime:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-monitor-elasticsearch:2019-CU4-ubuntu-16.04 \
mcr.microsoft.com/mssql/bdc/mssql-ssis-app-runtime:2019-CU4-ubuntu-16.04 \
| xargs -P50 -n1 docker pull
echo
# Tagging SQL Server Big Data Cluster images
echo -e "[TASK 2]${CYAN} Tagging SQL Server Big Data Cluster images...${NC}"
docker tag mcr.microsoft.com/mssql/bdc/mssql-app-service-proxy:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-app-service-proxy:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-control-watchdog:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-control-watchdog:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-controller:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-controller:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-dns:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-dns:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-hadoop:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-hadoop:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-mleap-serving-runtime:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-mleap-serving-runtime:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-mlserver-py-runtime:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-mlserver-py-runtime:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-mlserver-r-runtime:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-mlserver-r-runtime:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-monitor-collectd:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-monitor-collectd:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-monitor-elasticsearch:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-monitor-elasticsearch:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-monitor-fluentbit:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-monitor-fluentbit:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-monitor-grafana:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-monitor-grafana:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-monitor-influxdb:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-monitor-influxdb:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-monitor-kibana:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-monitor-kibana:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-monitor-telegraf:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-monitor-telegraf:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-security-domainctl:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-security-domainctl:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-security-knox:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-security-knox:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-security-support:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-security-support:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-server:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-server:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-server-controller:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-server-controller:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-server-data:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-server-data:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-ha-operator:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-ha-operator:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-ha-supervisor:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-ha-supervisor:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-service-proxy:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-service-proxy:2019-CU4-ubuntu-16.04
docker tag mcr.microsoft.com/mssql/bdc/mssql-ssis-app-runtime:2019-CU4-ubuntu-16.04 sys-dtr:5000/mssql/bdc/mssql-ssis-app-runtime:2019-CU4-ubuntu-16.04
echo
# Pushing SQL Server Big Data Cluster images to local registry
echo -e "[TASK 3]${CYAN} Pushing SQL Server Big Data Cluster images to local registry...${NC}"
echo \
sys-dtr:5000/mssql/bdc/mssql-app-service-proxy:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-control-watchdog:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-dns:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-mleap-serving-runtime:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-monitor-fluentbit:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-monitor-grafana:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-monitor-influxdb:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-monitor-kibana:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-monitor-telegraf:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-security-domainctl:2019-CU4-ubuntu-16.04 \
| xargs -P50 -n1 docker push
echo
echo \
sys-dtr:5000/mssql/bdc/mssql-security-knox:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-security-support:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-ha-operator:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-ha-supervisor:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-service-proxy:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-monitor-collectd:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-mlserver-py-runtime:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-server:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-server-controller:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-controller:2019-CU4-ubuntu-16.04 \
| xargs -P50 -n1 docker push
echo
echo \
sys-dtr:5000/mssql/bdc/mssql-server-data:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-hadoop:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-mlserver-r-runtime:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-monitor-elasticsearch:2019-CU4-ubuntu-16.04 \
sys-dtr:5000/mssql/bdc/mssql-ssis-app-runtime:2019-CU4-ubuntu-16.04 \
| xargs -P50 -n1 docker push
echo
echo -e "${GREEN} All SQL BDC CU4 images pulled to local registry ${NC}"
echo
docker rmi mcr.microsoft.com/mssql/bdc/mssql-app-service-proxy:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-app-service-proxy:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-control-watchdog:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-control-watchdog:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-controller:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-controller:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-dns:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-dns:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-hadoop:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-hadoop:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-mleap-serving-runtime:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-mleap-serving-runtime:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-mlserver-py-runtime:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-mlserver-py-runtime:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-mlserver-r-runtime:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-mlserver-r-runtime:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-monitor-collectd:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-monitor-collectd:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-monitor-elasticsearch:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-monitor-elasticsearch:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-monitor-fluentbit:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-monitor-fluentbit:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-monitor-grafana:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-monitor-grafana:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-monitor-influxdb:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-monitor-influxdb:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-monitor-kibana:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-monitor-kibana:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-monitor-telegraf:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-monitor-telegraf:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-security-domainctl:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-security-domainctl:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-security-knox:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-security-knox:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-security-support:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-security-support:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-server:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-server:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-server-controller:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-server-controller:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-server-data:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-server-data:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-ha-operator:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-ha-operator:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-ha-supervisor:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-ha-supervisor:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-service-proxy:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-service-proxy:2019-CU4-ubuntu-16.04
docker rmi mcr.microsoft.com/mssql/bdc/mssql-ssis-app-runtime:2019-CU4-ubuntu-16.04 
docker rmi sys-dtr:5000/mssql/bdc/mssql-ssis-app-runtime:2019-CU4-ubuntu-16.04
echo
#
echo -e "${GREEN} Local images cleanup completed ${NC}"