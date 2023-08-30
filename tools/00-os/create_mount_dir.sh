#!/bin/bash

function create_mount_dir() {
    name="$1"
    disks_dir="/sususu/disks"
    locals_dir="/sususu/locals"

    # create dir
    mkdir -p "$disks_dir/$name/volume0"
    mkdir -p "$locals_dir/$name/volume0"

    # mount
    sudo mount --bind "$disks_dir/$name/volume0" "$locals_dir/$name/volume0"

    # persist
    echo "$disks_dir/$name/volume0 $locals_dir/$name/volume0 none bind 0 0" | sudo tee -a /etc/fstab
}

# check param
if [ -z "$1" ]; then
    echo "You must pass an dir name"
else
    create_mount_dir "$1"
fi
