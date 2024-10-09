#!/bin/bash


mkdir -p base_images
rm -rf base_images/*

images=(
registry.k8s.io/ingress-nginx/controller:v1.10.0
registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.0
)


for imageName in "${images[@]}" ; do
#    docker pull $imageName

    tag=$(echo "$imageName" | cut -d "/" -f3)
    echo "----tag: ${tag}"
    docker save -o base_images/$tag.tar $imageName
done

