#!/bin/bash


mkdir -p temp_images
rm -rf temp_images/*

# if you cannot get images from k8s.io, you can use this tool
images=(
registry.k8s.io/kube-apiserver:v1.29.2
registry.k8s.io/kube-controller-manager:v1.29.2
registry.k8s.io/kube-scheduler:v1.29.2
registry.k8s.io/kube-proxy:v1.29.2
registry.k8s.io/coredns/coredns:v1.11.1
registry.k8s.io/pause:3.8
registry.k8s.io/pause:3.9
registry.k8s.io/etcd:3.5.10-0
)


for imageName in "${images[@]}" ; do
#    docker pull $imageName

    tag=$(echo "$imageName" | cut -d "/" -f2)

    docker save -o temp_images/$tag.tar $imageName
done

