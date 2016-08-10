#!/bin/ash
opkg update
opkg install block-mount kmod-fs-ext4 kmod-usb-storage-extras
opkg install e2fsprogs fdisk swap-utils
if fdisk -l |grep '/dev/mmcblk0' > /dev/null; then
    echo "Start"
else
    echo "/dev/mmcblk0 not found!"
    exit 0
fi
SDSize=`fdisk -l /dev/mmcblk0 | grep -m1 ^Disk | awk '{print $5}'`
SDSize='+'$((($SDSize/1024/1024)-256))'M'
echo  $SDSize
dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=10
(echo n; echo p; echo 1; echo; echo $SDSize; echo n; echo p; echo '2'; echo; echo; echo t; echo '2'; echo '82'; echo w) | fdisk /dev/mmcblk0
/usr/sbin/swapoff -a
/usr/sbin/mkswap /dev/mmcblk0p2
/usr/sbin/swapon -a
if fdisk -l |grep /dev/mmcblk0p1 > /dev/null; then
umount -f /dev/mmcblk0p1
fi
mkfs.ext4 /dev/mmcblk0p1
block detect > /etc/config/fstab
uci set fstab.@mount[0].target='/overlay'
uci set fstab.@mount[0].fstype='ext4'
uci set fstab.@mount[0].enabled_fsck='0'
uci set fstab.@mount[0].options='rw,sync,noatime,nodiratime'
uci set fstab.@mount[0].enabled='1'
uci set fstab.@swap[0].enabled='1'
uci commit fstab
mount /dev/mmcblk0p1 /mnt ; tar -C /overlay -cvf - . | tar -C /mnt -xf - ; umount /mnt
sync
reboot -f
