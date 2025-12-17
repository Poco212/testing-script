efi_path=/dev/nvme0n1p1
linux_path=/dev/nvme0n1p4
root_path=/dev/nvme0n1p5
home_path=/dev/nvme0n1p6

# root partition
function root_partition {
yes | mkfs.ext4 $root_path &&
mount $root_path /mnt
}
root_partition
clear &
echo "root partition done" &&
sleep 2 &&

# linux partition
clear &&
function linux_partition {
yes | mkfs.ext4 $linux_path &&
mkdir -p /mnt/boot &&
mount $linux_path /mnt/boot
}
linux_partition
clear &
echo "linux partition done" &&
sleep 2 &&


# efi partition
clear &&
function efi_partition {
mkdir -p /mnt/boot/efi &&
mount $efi_path /mnt/boot/efi
}
efi_partition
clear &&
echo "efi partition done" &&
sleep 2

# home partition
clear &&
function home_partition {
mkdir -p /mnt/home &&
yes | mkfs.ext4 $home_path &&
mount $home_path /mnt/home
}
home_partition
clear &&
echo "home partition done" &&
sleep 2

# package 
clear &&
function packages {
pacstrap /mnt base base-devel linux-zen linux-firmware intel-ucode mkinitcpio git neovim grub os-prober efibootmgr --noconfirm &&
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
ln -sf /usr/share/zoneinfo/Asia/Jakarta /mnt/etc/localtime &&
arch-chroot /mnt hwclock --systohc &&
arch-chroot /mnt timedatectl set-ntp true &&
arch-chroot /mnt timedatectl set-timezone Asia/Jakarta &&
arch-chroot /mnt timedatectl status &&
arch-chroot /mnt timedatectl show-timesync --all &&
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
echo "root=/dev/nvme0n1p5" > /mnt/etc/cmdline.d/01-boot.conf &&
echo "rw" > /mnt/etc/cmdline.d/06-misc.conf &&
clear &&
echo "cmdline done"
sleep 2

#grub install
clear &&
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch &&
echo 'GRUB_DISABLE_OS_PROBER=false' >> /mnt/etc/default/grub
clear &&
echo "grub install done"
sleep 2

#mkinitcpio
clear &&
mkdir -p /mnt/boot/kernel /mnt/boot/efi/linux &&
mv /mnt/boot/*-ucode.img /mnt/boot/vmlinuz-* /mnt/boot/kernel &&
mv -f /mnt/etc/mkinitcpio.conf /mnt/etc/mkinitcpio.d/default.conf &&
echo "#linux zen default" > /mnt/etc/mkinitcpio.d/default.conf &&
export CPIOHOOK="base systemd autodetect microcode modconf kms keyboard block filesystems fsck" &&
printf "MODULES=()\nBINARIES=()\nFILES=()\nHOOKS=($CPIOHOOK)" >> /mnt/etc/mkinitcpio.d/default.conf &&
clear &&
echo "mkinitcpio done"
sleep 2

#efi generate
clear &&
echo "#linux zen preset" > /mnt/etc/mkinitcpio.d/linux-zen.preset &&
echo 'ALL_config="/etc/mkinitcpio.d/default.conf"' >> /mnt/etc/mkinitcpio.d/linux-zen.preset &&
echo 'ALL_kver="/boot/kernel/vmlinuz-linux-zen"' >> /mnt/etc/mkinitcpio.d/linux-zen.preset &&
echo "PRESETS=('default')" >> /mnt/etc/mkinitcpio.d/linux-zen.preset &&
echo 'default_image="/boot/initramfs-linux-zen.img"' >> /mnt/etc/mkinitcpio.d/linux-zen.preset &&
echo 'default_uki="/boot/efi/linux/arch-linux-zen.efi"' >> /mnt/etc/mkinitcpio.d/linux-zen.preset &&
arch-chroot /mnt mkinitcpio -P
sleep 2
echo "efi generate done"

#create entries 
#EFI_UUID=$(blkid -s UUID -o value $efi_path)
#cat << EOF >> /mnt/etc/grub.d/40_custom
#menuentry "Arch Linux" {
#    insmod fat
#    insmod chain
#    search --no-floppy --set=root --fs-uuid $EFI_UUID
#    chainloader /linux/arch-linux-zen.efi
#}
#EOF
clear &&
cat << EOF >> /mnt/etc/grub.d/40_custom
menuentry "Arch Linux" {
    linux /kernel/vmlinuz-linux-zen
    initrd /kernel/intel-ucode.img
    initrd /initramfs-linux-zen.img
}
EOF
clear &&
echo "entry done"
sleep 2

#generate grub
clear &&
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
