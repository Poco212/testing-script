!/bin/bash
EFI=/dev/
BOOT=/dev/
ROOT=/dev/
HOME=/dev

# root partition
echo " prepare root partition"

mkfs.ext4 /dev/$ROOT &&
mount /dev/$ROOT /mnt &&

echo " created root partition"

# boot partition
echo " prepare boot partition"

mkdir -p /mnt/boot &&
mkfs.ext4 /dev/$BOOT &&
mount /dev/$BOOT /mnt/boot &&

echo " created boot partition"

# efi partition

echo " prepare efi partition"

mkdir -p /mnt/boot/efi &&
mount /dev/$EFI /mnt/boot/efi &&

echo " created efi partition"

# home partition

echo " prepare home partition"

mkdir -p /mnt/home &&
mkfs.ext4 /dev/$HOME &&
mount /dev/$HOME /mnt/home &&

echo " create home partition" 
