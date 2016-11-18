#!/bin/sh

die() { echo "$@" 1>&2 ; exit 1; }

[ "$#" -eq 1 ] || die "Usage : device block name required (ex: $0 sda)"


sudo udevadm info --query=all --path=/sys/block/$1 | grep -E "BUS|MODEL=|VENDOR="
