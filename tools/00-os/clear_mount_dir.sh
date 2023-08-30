#!/bin/bash

set -e

function clear_mount_dir() {
  name="$1"
  volume_param="$2"
  disks_dir="/sususu/disks"
  locals_dir="/sususu/locals"

  for i in $(seq 0 "${volume_param:-0}"); do
    volume="volume$i"
    locals_volume_dir="$locals_dir/$name/$volume"
    if [ -d "$locals_volume_dir" ]; then
      sudo umount "$locals_dir/$name/$volume"
      # shellcheck disable=SC2115
      rm -rf $locals_dir/$name/$volume/*
      # shellcheck disable=SC2115
      rm -rf $disks_dir/$name/$volume/*
      sudo mount --bind "$disks_dir/$name/$volume" "$locals_dir/$name/$volume"
    fi
  done
}

# check param
if [ -z "$1" ]; then
  echo "You must pass at least a dir name"
else
  clear_mount_dir "$1" "$2"
fi
