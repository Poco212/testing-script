NAME=null
PASS=1511
EFI=/dev/nvme0n1p1
BOOT=/dev/nvme0n1p5
ROOT=/dev/nvme0n1p6
HOMEE=/dev/nvme0n1p7

# root partition
function root_partition {
yes | mkfs.ext4 $ROOT &&
mount $ROOT /mnt
}

root_partition
clear &&
echo "root partition done" &&
sleep 2 &&
# boot partition
clear &&
function boot_partition {
mkdir -p /mnt/boot &&
yes | mkfs.ext4 $BOOT &&
mount $BOOT /mnt/boot
}

boot_partition
clear &&
echo "boot partition done" &&
sleep 2 &&

# efi partition
clear &&
function efi_partition {
mkdir -p /mnt/boot/efi &&
mount $EFI /mnt/boot/efi
}

efi_partition
clear &&
echo "efi partition done" &&
sleep 2

# home partition
clear &&
function home_partition {
mkdir -p /mnt/home &&
yes | mkfs.ext4 $HOMEE &&
mount $HOMEE /mnt/home
}

home_partition
clear &&
echo "home partition done" &&
sleep 2

# package 
clear &&
function packages {
pacstrap /mnt base base-devel linux-zen linux-firmware intel-ucode mkinitcpio git neovim --noconfirm &&
genfstab -U /mnt >> /mnt/etc/fstab
}

packages
clear &&
echo " packages installed"
sleep 2

# chroot

arch-chroot /mnt post/install.sh
