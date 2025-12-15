EFI=/dev/sda1
ROOT=/dev/sdb2
HOMEE=/dev/sdb3

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

#locale
clear &&
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen &&
arch-chroot /mnt locale-gen &&
clear &&
echo "timedate done"
sleep 2

#useradd
clear &&
arch-chroot /mnt useradd -m test &&
arch-chroot /mnt passwd test &&
echo "test ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/nologin &&
clear &&
echo "username done"
sleep 2

#cmdline
clear &&
mkdir -p /mnt/etc/cmdline.d &&
touch /mnt/etc/cmdline.d/{01-boot.conf,02-mods.conf,03-secs.conf,04-perf.conf,05-nets.conf,06-misc.conf} &&
echo "root=/dev/sdb2" > /mnt/etc/cmdline.d/01-boot.conf &&
echo "rw" > /mnt/etc/cmdline.d/06-misc.conf &&
clear &&
echo "cmdline done"
sleep 2

#boot
clear &&
rm -fr /mnt/boot/initramfs-* &&
mkdir -p /mnt/boot/kernel /mnt/boot/efi/EFI/Linux &&
mv /mnt/boot/*-ucode.img /mnt/boot/vmlinuz-* /mnt/boot/kernel 
