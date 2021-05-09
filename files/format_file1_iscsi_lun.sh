#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Format iSCSI partitions
# ------------------------------------------------------------------------------

lun_dev="/dev/$(lsblk --scsi|sed -ne '/\Wfile1\W/s/^\(\S*\).*/\1/p')"

if [[ ! -e "${lun_dev}1" ]]
then
    gdisk "${lun_dev}" <<DONE
n




p
w
y
DONE
    printf "Added partition to %s\n" "${lun_dev}"
else
    printf "Partition already exists on iSCSI LUN\n"
fi

if ! fsadm check "${lun_dev}1"
then
    mkfs -t ext4 "${lun_dev}1"
    printf "Added ext4 file system to %s\n" "${lun_dev}1"
else
    printf "Ext4 file system already exists on %s\n" "${lun_dev}1"
fi

mp=/media/file1
mkdir -p "${mp}"
uuid=$(lsblk --noheadings --output uuid "${lun_dev}1")

if ! grep -q "${mp}" /etc/fstab
then
    cat >>/etc/fstab <<DONE
UUID="${uuid}" ${mp} ext4 _netdev 0 0
DONE
    printf "Added iSCSI LUN to fstab\n"
else
    printf "iSCSI LUN already in fstab\n"
fi

mount -a
lsblk

