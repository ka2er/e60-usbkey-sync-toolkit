#!/bin/sh
#
# This script looks up the partition label and
# type, creates /media/LABEL and mounts the partition.  Mount options
# are hard-coded below.
# Then is sync music folder and unmount media when done.
# To warn user, the script emit a serie of beeps and mails

DEVICE="/dev/e60-usbkey"

# check input
if [ -z "$DEVICE" ]; then
   exit 1
fi

# test that this device isn't already mounted
device_is_mounted=`grep ${DEVICE} /etc/mtab`
if [ -n "$device_is_mounted" ]; then
   echo "error: seems ${DEVICE} is already mounted"
   exit 1
fi

if [ -z "$ID_FS_LABEL" ] || [ -z "$ID_FS_TYPE" ]; then
   echo "error: ID_FS_LABEL is empty! tried ${DEVICE}"
   exit 1
fi


# test mountpoint - it shouldn't exist
if [ ! -e "/media/${ID_FS_LABEL}" ]; then

   env | mailx -s "[E60] sync START" __EMAIL__

   # make the mountpoint
   mkdir "/media/${ID_FS_LABEL}"

   # mount the device
   mount -t auto -o sync,noatime ${DEVICE} "/media/${ID_FS_LABEL}"
   MOUNT_STATUS=$?

   # rsync music
   rsync -a --inplace --no-whole-file --progress --no-z --no-o --no-p --no-g -L --safe-links --modify-window 1 --stats --delete __RSYNC_SOURCE__ "/media/${ID_FS_LABEL}"
   RSYNC_STATUS=$?
	
   # umount
   umount "/media/${ID_FS_LABEL}"
   UNMOUNT_STATUS=$?

   # delete mount point 
   rmdir "/media/${ID_FS_LABEL}"
   RMDIR_STATUS=$?

   # inform user
   beep -r 2 -d 200 -n -f 100 -r 2 -d 100
   STATUS=$([ "$RSYNC_STATUS" == 0 ] && echo "OK" || echo "KO")
   echo "MOUNT:$MOUNT_STATUS \nRSYNC:$RSYNC_STATUS \nUNMOUNT:$UNMOUNT_STATUS \nRMDIR:$RMDIR_STATUS" | mailx -s "[E60] sync $STATUS" __EMAIL__
   # all done here, return successful
   exit 0
fi

exit 1
