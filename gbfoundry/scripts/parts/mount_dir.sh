#!/bin/bash

set -e

function create_mount_dir() {
  name="$1"
  volume_param="$2"
  disks_dir="/data/disks"
  locals_dir="/data/locals"

  for i in $(seq 0 "${volume_param:-0}"); do
    volume="volume$i"
    disks_volume_dir="$disks_dir/$name/$volume"
    if [ ! -d "$disks_volume_dir" ]; then
      mkdir -p "$disks_dir/$name/$volume"
      mkdir -p "$locals_dir/$name/$volume"
      sudo mount --bind "$disks_dir/$name/$volume" "$locals_dir/$name/$volume"
      echo "$disks_dir/$name/$volume $locals_dir/$name/$volume none bind 0 0" | sudo tee -a /etc/fstab
    fi
  done
}

# check param
if [ -z "$1" ]; then
  echo "You must pass at least a dir name"
else
  create_mount_dir "$1" "$2"
fi
