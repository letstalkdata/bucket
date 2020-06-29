#!/bin/bash
#
mkfs.xfs /dev/loop15
mkdir /mnt/dvc1
mount -t xfs /dev/loop15 /mnt/dvc1
