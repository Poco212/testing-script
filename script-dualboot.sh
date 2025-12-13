!/bin/bash
EFI=/dev/
BOOT=/dev/
ROOT=/dev/
HOME=/dev

# root partition
function root_partition {
mkfs.ext4 /dev/$ROOT &&
mount /dev/$ROOT /mnt &&
}

root_partition
# boot partition

function boot_partition {
mkdir -p /mnt/boot &&
mkfs.ext4 /dev/$BOOT &&
mount /dev/$BOOT /mnt/boot &&
}

boot_partition

# efi partition

function efi_partition {
mkdir -p /mnt/boot/efi &&
mount /dev/$EFI /mnt/boot/efi &&
}

# home partition

function home_partition {
mkdir -p /mnt/home &&
mkfs.ext4 /dev/$HOME &&
mount /dev/$HOME /mnt/home &&
}

# package 

function package {
pacstrap /mnt base base-devel linux-zen linux-firmware intel-ucode git neovim --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
}

# chroot

arch-chroot /mnt
