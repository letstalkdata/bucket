#!/bin/bash
#
mknod /dev/kmsg c 1 11 > /dev/null 2>&1
kubeadm join 10.6.230.88:6443 --token cfi2mt.b13wocfylzugdi0p     --discovery-token-ca-cert-hash sha256:c4eb0a75c9924c3cdeb2a3605399429f37befcb883d7a88554d4e2f83deb4f41  --ignore-preflight-errors=all >> /root/nodejoin.log 2>&1
