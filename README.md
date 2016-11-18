# e60-usbkey-sync-toolkit
This repo contains install script to automate update of my music usb key

## Purpose

In order to automate the way my music USB key is filled and synced from my NAS, I build the following approach :

* 1 installer
* 1 udev rules that detect my USB key
* 1 script that get called and rsync news music to the stick

## Install

Just use the lightweight installer with the following params (USB stick plugged)

* USB stick device block name (sda, sdb, sdc, ...)
* an email to receive notification (usefull on large rsync to get notified on finish)
* absolute path to the source folder with trailing slash (aka my music folder)

```
usage: ./install.sh -d <device_block_name> -p <rsync_path> -e <email>

	exemple : ./install.sh -d sda -p /rsync_from/ -e user@email.org
```

## Usage

Just plug the USB stick and wait for the mail with status subject. If all status are 0 you can safely unplug the stick

