#!/bin/bash
#
mknod /dev/kmsg c 1 11 > /dev/null 2>&1
kubeadm join 10.6.230.207:6443 --token wxgxw2.v2iz2t2m4t7mxbhj     --discovery-token-ca-cert-hash sha256:a1ce8e4e79e85150ba20662cffb3efd5c55bc80672f0bdb98cd70d78b6b01f07  --ignore-preflight-errors=all >> /root/nodejoin.log 2>&1
