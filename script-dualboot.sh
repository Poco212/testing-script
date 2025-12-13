NAME=null
PASS=1511
EFI=/dev/nvme0n1p1
BOOT=/dev/nvme0n1p5
ROOT=/dev/nvme0n1p6
HOME=/dev/nvme0n1p7

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

function efi_partition {
mkdir -p /mnt/boot/efi &&
mount $EFI /mnt/boot/efi
}

efi_partition

# home partition

function home_partition {
mkdir -p /mnt/home &&
yes | mkfs.ext4 $HOME &&
mount $HOME /mnt/home
}

home_partition

# package 

function packages {
pacstrap /mnt base base-devel linux-zen linux-firmware intel-ucode mkinitcpio git neovim --noconfirm &&
genfstab -U /mnt >> /mnt/etc/fstab
}

packages

# chroot

arch-chroot /mnt

#hostname

function hostname {
echo "testing" > /etc/hostname
}

hostname
echo "hostname done"

#zoneinfo
