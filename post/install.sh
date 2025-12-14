#!/bin/bash

#hostname
echo "testing" > /etc/hostname &&
clear &&
echo "hostname done"
sleep 2

#timectl
clear &&
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime &&
hwclock --systohc &&
timedatectl set-ntp true &&
timedatectl set-timezone Asia/Jakarta &&
timedatectl status &&
timedatectl show-timesync --all &&
clear &&
echo "timedate done"
sleep 2

#locale
clear &&
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen &&
locale-gen &&
clear &&
echo "locale done"
sleep 2

#useradd
clear &&
useradd -m test &&
passwd test &&
echo "test ALL=(ALL:ALL) ALL" > /etc/sudoers.d/nologin &&
clear &&
echo "username done"
sleep 2

#cmdline
clear &&
mkdir -p /etc/cmdline.d &&
touch /etc/cmdline.d/{01-boot.conf,02-mods.conf,03-secs.conf,04-perf.conf,05-nets.conf,06-misc.conf} &&
echo "root=/dev/nvme0n1p6" > /etc/cmdline.d/01-boot.conf &&
echo "rw" > /etc/cmdline.d/06-misc.conf &&
clear &&
echo "cmdline done"
sleep 2

#boot
clear &&
rm -fr /boot/initramfs-* &&
mkdir -p /boot/kernel /boot/efi/EFI/Linux &&
mv /boot/*-ucode.img /boot/vmlinuz-* /boot/kernel &&
bootctl --path=/boot/efi install &&
clear &&
echo "boot done"
sleep 2

#entries
clear &&
rm -fr /boot/EFI /boot/loader/entries &&
mv -f /boot/efi/EFI/Microsoft/Boot/bootmgfw.efi /boot/efi/EFI/Microsoft/Boot/bootmgfw.efi.bak &&
cp /boot/efi/EFI/systemd/systemd-bootx64.efi /boot/efi/EFI/Microsoft/Boot/bootmgfw.efi &&
mkdir -p /boot/efi/loader/entries &&
cat << 'EOF' > /boot/efi/loader/entries/windows.conf
title  windows boot manager
efi    /EFI/Microsoft/Boot/bootmgfw.efi.bak
EOF
clear &&
echo "entries done"
sleep 2

#loader 
clear &&
cat << 'EOF' > /boot/efi/loader/loader.conf
timeout 3
auto-entries 0
EOF
clear &&
echo "loader done"
sleep 2

#mkinitcpio
clear &&
mv /etc/mkinitcpio.conf /etc/mkinitcpio.d/default.conf &&
echo "#linux zen default" > /etc/mkinitcpio.d/default.conf &&
export CPIOHOOK="base systemd autodetect microcode modconf kms keyboard block filesystems fsck" &&
printf "MODULES=()\nBINARIES=()\nFILES=()\nHOOKS=($CPIOHOOK)" >> /etc/mkinitcpio.d/default.conf &&
clear &&
echo "mkinitcpio done"
sleep 2

#efi generate
clear &&
echo "#linux zen preset" > /etc/mkinitcpio.d/linux-zen.preset &&
echo 'ALL_config="/etc/mkinitcpio.d/default.conf"' >> /etc/mkinitcpio.d/linux-zen.preset &&
echo 'ALL_kver="/boot/kernel/vmlinuz-linux-zen"' >> /etc/mkinitcpio.d/linux-zen.preset &&
echo "PRESETS=('default')" >> /etc/mkinitcpio.d/linux-zen.preset &&
echo 'default_uki="/boot/efi/EFI/Linux/arch-linux-zen.efi"' >> /etc/mkinitcpio.d/linux-zen.preset &&
bootctl update &&
mkinitcpio -P
