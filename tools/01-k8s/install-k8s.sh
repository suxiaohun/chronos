


sudo kubeadm reset -f
rm -rf /etc/cni/net.
rm -rf $HOME/.kube/config


sudo kubeadm -v 5 init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

