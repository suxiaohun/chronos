#!/bin/sh

function tag_and_import() {
  imageRegistry="10.4.243.51:5000"
  imageid="$1"
  imagename=$(docker images | grep $imageid | awk '{print $1}' | xargs basename)
  imageversion=$(docker images | grep $imageid | awk '{print $2}')

  docker tag $imageid "$imageRegistry/$imagename:$imageversion"
  docker save -o $imagename.tar "$imageRegistry/$imagename:$imageversion"
  ctr -n k8s.io images import $imagename.tar
  rm $imagename.tar
}

# check param
if [ -z "$1" ]; then
  echo "Please pass imageid"
else
  tag_and_import "$1"
fi
