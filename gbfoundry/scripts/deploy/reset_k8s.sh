#! /bin/bash

kubeadm reset -f --cri-socket unix:///var/run/cri-dockerd.sock
rm -rf /etc/cni/net.d
rm -rf $HOME/.kube/config

rm -rf /data/nova/gbfoundry/.k8s_cluster_deployed


