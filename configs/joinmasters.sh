#!/bin/bash
#
mknod /dev/kmsg c 1 11 > /dev/null 2>&1
  kubeadm join 10.6.230.207:6443 --token 45cvgt.33is3ch4vdn52w99 \
    --discovery-token-ca-cert-hash sha256:a1ce8e4e79e85150ba20662cffb3efd5c55bc80672f0bdb98cd70d78b6b01f07 \
    --experimental-control-plane --certificate-key c11754d9a9aa5e3cfaf284142bc787446d79ea95c950276730505aad40bc2dc6 --ignore-preflight-errors=all >> /root/nodejoin.log 2>&1
