#! /bin/bash

if [ -f /data/nova/gbfoundry/.k8s_cluster_deployed ]; then
  echo "Cluster deployed. Skip......"
else
   kubeadm -v=5 init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock  --image-repository 10.100.11.110:8080/infra/k8s --kubernetes-version v1.28.13

   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config

   export KUBECONFIG=/etc/kubernetes/admin.conf

   kubectl create -f /data/nova/gbfoundry/packages/calico/tigera-operator.yaml
   kubectl create -f /data/nova/gbfoundry/packages/calico/custom-resources.yaml

   kubectl get nodes

   while true; do
     # 获取所有 master 节点的状态
     ready_nodes=$(kubectl get nodes --selector='node-role.kubernetes.io/control-plane' -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}')

     # 检查 master 节点的 Ready 状态
     if [[ "$ready_nodes" =~ "True" ]]; then
       echo "Master node is ready!"
       break
     else
       echo "Waiting for master node to be ready..."
       sleep 10  # 等待 10 秒后重试
     fi
   done

   kubectl get nodes

   kubectl taint nodes --all node-role.kubernetes.io/control-plane-
   touch /data/nova/gbfoundry/.k8s_cluster_deployed
fi

cc=$(kubeadm token create --print-join-command)
echo "$cc --cri-socket unix:///var/run/cri-dockerd.sock" > /data/nova/gbfoundry/.k8s_join_command.sh
ansible-playbook -v  -i /data/nova/gbfoundry/inventory /data/nova/gbfoundry/infra.yaml
kubectl get nodes

sh scripts/deploy/install_helm_tools.sh

# todo move this action to other place
sh scripts/parts/mount_dir.sh loki
sh scripts/parts/mount_dir.sh prometheus
sh scripts/parts/mount_dir.sh jenkins
sh scripts/parts/mount_dir.sh grafana



