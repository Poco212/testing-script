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
