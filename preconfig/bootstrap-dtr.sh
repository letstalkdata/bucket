#!/bin/bash
#
ip=`hostname -I | awk '{print $1}'`
hs=$(hostname)
#
yum -y install openssl 
mkdir -p /certs
#
# Creating and uploading certificate
echo "[TASK 1] Creating and uploading certificate"
cn="IN"
st="Karnataka"
loc="Bangalore" 
on="Dell" 
ou="BizApp" 
email="s_ranjan@dell.com"
umask 77 ; echo "$cn
$st
$loc
$on
$ou
$hs
$ip
$ip
$email" | openssl req -newkey rsa:4096 -nodes -sha256 -keyout /certs/ca.key -x509 -days 365 -out /certs/ca.crt
echo
certLoc="/etc/docker/certs.d/$hs:5000"
mkdir -p $certLoc
cp /certs/ca.crt $certLoc/ca.crt
#
# Setting up Local docker registry
echo "[TASK 2] Setting up Local docker registry"
docker pull registry:2 >/dev/null 2>&1
#
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /home/dockerv/registry:/var/lib/registry \
  -v /certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/ca.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/ca.key \
  registry:2
#
# Uploading required images to Local docker registry
echo "[TASK 3] Uploading required images to Local docker registry"
# Flannel image
docker load < /root/flannel.tar.gz >/dev/null 2>&1
docker push sys-dtr:5000/cni/flannel:v0.12.0-amd64 >/dev/null 2>&1
docker rmi sys-dtr:5000/cni/flannel:v0.12.0-amd64 >/dev/null 2>&1
#
## Kubernetes dashboard images
# Dashboard
docker pull k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0 >/dev/null 2>&1
docker tag k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0 sys-dtr:5000/k8s/dashboard/kubernetes-dashboard-amd64:v1.10.0
docker push sys-dtr:5000/k8s/dashboard/kubernetes-dashboard-amd64:v1.10.0 >/dev/null 2>&1
#Heapster
docker pull k8s.gcr.io/heapster-amd64:v1.5.4 >/dev/null 2>&1
docker tag k8s.gcr.io/heapster-amd64:v1.5.4 sys-dtr:5000/k8s/dashboard/heapster-amd64:v1.5.4
docker push sys-dtr:5000/k8s/dashboard/heapster-amd64:v1.5.4 >/dev/null 2>&1
#InfluxDB
docker pull k8s.gcr.io/heapster-influxdb-amd64:v1.5.2 >/dev/null 2>&1
docker tag k8s.gcr.io/heapster-influxdb-amd64:v1.5.2 sys-dtr:5000/k8s/dashboard/heapster-influxdb-amd64:v1.5.2
docker push sys-dtr:5000/k8s/dashboard/heapster-influxdb-amd64:v1.5.2 >/dev/null 2>&1
#Cleanup
docker rmi sys-dtr:5000/k8s/dashboard/kubernetes-dashboard-amd64:v1.10.0 >/dev/null 2>&1
docker rmi k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0 >/dev/null 2>&1
docker rmi sys-dtr:5000/k8s/dashboard/heapster-amd64:v1.5.4 >/dev/null 2>&1
docker rmi k8s.gcr.io/heapster-amd64:v1.5.4 >/dev/null 2>&1
docker rmi sys-dtr:5000/k8s/dashboard/heapster-influxdb-amd64:v1.5.2 >/dev/null 2>&1
docker rmi k8s.gcr.io/heapster-influxdb-amd64:v1.5.2 >/dev/null 2>&1