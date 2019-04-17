#
# flash-sd.sh
# Do integrity checks for the SD card
# Flash rpi-android into a preformatted SD CARD
#
# Author: Mustafa Ozcelikors <mozcelikors@gmail.com>
#

#!/bin/bash

android_path=/media/mozcelikors/android_builds/rpi-android

lsblk

echo " "
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!! WARNING: ONLY ENTER YOUR SD CARD PATH. DO NOT ENTER /dev/sda!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo " "

read -p "Enter Device Path i.e. /dev/sdd: "  devpath

echo "You entered $devpath"

# Get mount point
mountpointp1=`grep "^${devpath}1 " /proc/mounts | cut -d ' ' -f 2`
echo "Mount point: ${mountpointp1}"

if [ -z "$mountpointp1" ]; then
      echo "SD Card is not mounted, please replug SD card to continue.."
      exit 1;
fi

partitioncountplus1=`ls $devpath* | wc -l`
devpathminusdev=`echo $devpath |  sed "s/\/dev\///g"`
#echo $devpathminusdev
devicespace=`awk '/sd[a-e]$/{printf "%s %8.2f\n", $NF, $(NF-1) / 1024 / 1024}' /proc/partitions |  sed "s/ //g" |  sed  "s/$devpathminusdev//g" | sed '/^sd/d'`
echo "$devicespace GiB space on the drive.."

# Check device space
if [[ ${devicespace%.*} -gt 32 ]]; then
    echo "Device has more than 32GiBs, This looks funny!"
    exit 1
fi

# Check if device has 4 partitions
if [ "$partitioncountplus1" != "5" ]; then
    echo "You must first partition the SD card!"
    echo "  p1 512MB for BOOT : Do fdisk : W95 FAT32(LBA) & Bootable, mkfs.vfat"
    echo "  p2 512MB for /system : Do fdisk, new primary partition"
    echo "  p3 512MB for /cache  : Do fdisk, mkfs.ext4"
    echo "  p4 remainings for /data : Do fdisk, mkfs.ext4"
    exit 1;
fi

echo "Writing system image to SD card..."
echo "Checking if path is valid.."
if [ "${devpath}2" != "/dev/sda" ]; then
    echo "Entered device path is valid."
    sudo dd if=$android_path/out/target/product/rpi3/system.img of=${devpath}2 bs=1M

    echo "Copying boot partition..."
    mkdir -p $mountpointp1/overlays
    cp $android_path/device/brcm/rpi3/boot/* $mountpointp1
    cp $android_path/kernel/rpi/arch/arm/boot/zImage $mountpointp1
    cp $android_path/kernel/rpi/arch/arm/boot/dts/bcm2710-rpi-3-b.dtb $mountpointp1
    cp $android_path/kernel/rpi/arch/arm/boot/dts/overlays/vc4-kms-v3d.dtbo $mountpointp1/overlays/vc4-kms-v3d.dtbo
    cp $android_path/out/target/product/rpi3/ramdisk.img $mountpointp1
else
    echo "You can't enter /dev/sda!"
fi
