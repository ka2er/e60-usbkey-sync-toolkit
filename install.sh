#!/bin/bash

usage() {
	echo "usage: $0 -d <device_block_name> -p <rsync_path> -e <email>" >&2
	echo "" >&2
	echo "	exemple : $0 -d sda -p /rsync_frpm -e user@email.org" >&2
 }

optspec=":hd:e:p:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        h)
	    usage
            exit 2
            ;;
        d)
            DEVICE="${OPTARG}"
	    ;;
        e)
            EMAIL="${OPTARG}"
            ;;
        p)
            RSYNC_SOURCE="${OPTARG}"
            ;;
	\?)
	    echo "Unknown option: -$OPTARG" >&2; 
	    exit 1
	    ;;
   	:)
      	    echo "Option -$OPTARG requires an argument." >&2
      	    exit 1
      	    ;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "Non-option argument: '-${OPTARG}'" >&2
            fi
            ;;
    esac
done

## all mandatory parameters
if [[ ! $DEVICE ]] || [[ ! $EMAIL ]] || [[ ! $RSYNC_SOURCE ]]  
then
    usage
    exit 1
fi

read BUS MODEL VENDOR <<< $(./dump-usbkeyinfos.sh $DEVICE| cut -d = -f2)

cat <<EOT > 95-e60-usbkey-sync.rules
ACTION=="add", SUBSYSTEMS=="$BUS", ENV{ID_VENDOR}=="$VENDOR", ENV{ID_MODEL}=="$MODEL", SYMLINK+="e60-usbkey", RUN+="/usr/local/sbin/e60-usbkey-sync-wrapper.sh"
EOT

cp 95-e60-usbkey-sync.rules /etc/udev/rules.d/
cp e60-usbkey-sync-wrapper.sh /usr/local/sbin/
sed -n -e s/__EMAIL__/$EMAIL/ -e s#__RSYNC_SOURCE__#$RSYNC_SOURCE# -e p e60-usbkey-sync.sh > /usr/local/sbin/e60-usbkey-sync.sh
rm 95-e60-usbkey-sync.rules
