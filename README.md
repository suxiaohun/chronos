# Introduction
This is a complex project, involving k8s, helm, helmfile and other aspects of knowledge.

As we all know, containerization and automated deployment has always been a troublesome problem, and every company has its own solution.
 
### Goals
This project aims to provide a general solution for those who need.
(especially when it is not possible to directly connect to the external network in China)

You can obtain a complete k8s cluster within 10 minutes！

# Installation steps

### Preparation:

1. Servers which with a freshly installed operating system (only centos7 is supported now)
2. Private Harbor repository (if there is no Internet access)
 
### Steps:
1. Upload the `gbfoundry` dir to the server, it is recommended to put it under `/data/nova`
2. Modify the `inventory` file and configure your server information, including: ip, account and password
```
[master]
gb-1 ansible_host=10.100.11.119 ip=10.100.11.119 ansible_user=root ansible_ssh_pass='123qwe!@#'

[node]
gb-2 ansible_host=192.168.180.139 ip=192.168.180.139 ansible_user=root ansible_ssh_pass='123qwe!@#'
```
3. Execute `sh online-deploy.sh prepare`, which will install dependencies and docker, kubectl and other dependencies on all servers

Software versions:
- docker-ce-26.1.4-1.el7
- kubelet-1.28.13-150500.1.1
- kubeadm-1.28.13-150500.1.1 
- kubectl-1.28.13-150500.1.1

> Currently, only specific versions are supported, and they will be changed to configurable in the future

4. Execute `sh online-deploy.sh infra`, which will deploy the k8s cluster and add other nodes to the cluster
5. Execute `sh online-deploy.sh product`, which will deploy necessary charts, such as: prometheus, loki, etc.

After the above steps, you already have a complete k8s cluster and supporting services, you can adjust them as needed, congratulations!

---
# Tips
1. Use `docker` as the CRI, not `containerd`
2. Only support `Centos7`