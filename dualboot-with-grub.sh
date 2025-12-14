EFI=/dev/nvme0n1p1
ROOT=/dev/nvme0n1p5
HOMEE=/dev/nvme0n1p6

# root partition
function root_partition {
yes | mkfs.ext4 $ROOT &&
mount $ROOT /mnt
}

root_partition
clear &&
echo "root partition done" &&
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

#network
clear &&
function network {
mkdir -p /mnt/var/lib/iwd &&
cp /var/lib/iwd/*.psk /mnt/var/lib/iwd/
}

network

clear &&
echo "network configurated"
sleep 2

#hostname
echo "testing" > /mnt/etc/hostname &&
clear &&
echo "hostname done"
sleep 2

#timectl
clear &&
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime &&
arch-chroot /mnt hwclock --systohc &&
arch-chroot /mnt timedatectl set-ntp true &&
arch-chroot /mnt timedatectl set-timezone Asia/Jakarta &&
arch-chroot /mnt timedatectl status &&
arch-chroot /mnt timedatectl show-timesync --all &&
clear &&
echo "timedate done"
sleep 2
