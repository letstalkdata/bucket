#!/bin/bash
#
mknod /dev/kmsg c 1 11 > /dev/null 2>&1
  kubeadm join 10.6.230.88:6443 --token vtplug.4wjto8vd4xmu2ihs \
    --discovery-token-ca-cert-hash sha256:c4eb0a75c9924c3cdeb2a3605399429f37befcb883d7a88554d4e2f83deb4f41 \
    --experimental-control-plane --certificate-key 646f70ebcaabc40d03f80fb8d3cc102fc9c00c4ad09c27332380b8d7417664af --ignore-preflight-errors=all >> /root/nodejoin.log 2>&1
