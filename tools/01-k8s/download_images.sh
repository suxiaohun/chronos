#!/bin/bash


# if you cannot get images from k8s.io, you can use this tool
images=(
  k8s.gcr.io/kube-apiserver:v1.22.2
  k8s.gcr.io/kube-controller-manager:v1.22.2
  k8s.gcr.io/kube-scheduler:v1.22.2
  k8s.gcr.io/kube-proxy:v1.22.2
  k8s.gcr.io/pause:3.5
  k8s.gcr.io/etcd:3.5.0-0
  k8s.gcr.io/coredns/coredns:v1.8.4
)

for imageName in "${images[@]}" ; do
    docker pull registry.aliyuncs.com/google_containers/$imageName
    docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
    docker rmi registry.aliyuncs.com/google_containers/$imageName
done

