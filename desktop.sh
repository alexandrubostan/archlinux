#!/bin/bash

set -eo pipefail

EFI='/dev/nvme0n1p1'
ROOT='/dev/nvme0n1p2'
HOME='/dev/nvme0n1p3'
DRIVE='/dev/nvme0n1'
EFIPART=1

ext4fs () {
    mkfs.ext4 "$ROOT"
    mkfs.ext4 "$HOME"
    mount "$ROOT" /mnt
    mount --mkdir "$HOME" /mnt/home
    mount --mkdir "$EFI" /mnt/boot
}

ext4fs

pacstrap -K /mnt base linux linux-firmware vim sudo amd-ucode networkmanager
genfstab -U /mnt >> /mnt/etc/fstab

echo '%wheel      ALL=(ALL:ALL) NOPASSWD: ALL' | tee -a /mnt/etc/sudoers > /dev/null

sed -e '/en_US.UTF-8/s/^#*//' -i /mnt/etc/locale.gen
sed -e '/ro_RO.UTF-8/s/^#*//' -i /mnt/etc/locale.gen
sed -e '/ParallelDownloads/s/^#*//' -i /mnt/etc/pacman.conf

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt locale-gen

echo 'LANG=en_US.UTF-8' | tee /mnt/etc/locale.conf > /dev/null
echo 'ArchBox' | tee /mnt/etc/hostname > /dev/null
arch-chroot /mnt bootctl install

install_kde () {
    arch-chroot /mnt pacman -S --needed \
    breeze-gtk \
    drkonqi \
    kde-gtk-config \
    kdeplasma-addons \
    kgamma \
    kinfocenter \
    kscreen \
    ksshaskpass \
    kwallet-pam \
    kwrited \
    plasma-desktop \
    plasma-disks \
    plasma-nm \
    plasma-pa \
    plasma-systemmonitor \
    powerdevil \
    power-profiles-daemon \
    sddm-kcm \
    xdg-desktop-portal-kde \
    xdg-desktop-portal-gtk \
    konsole \
    dolphin \
    kate \
    filelight \
    ark \
    p7zip
    
    systemctl enable sddm.service --root=/mnt
}

install_gnome () {
    arch-chroot /mnt pacman -S --needed \
    baobab \
    gdm \
    gnome-calendar \
    gnome-characters \
    gnome-clocks \
    gnome-console \
    gnome-control-center \
    gnome-disk-utility \
    gnome-font-viewer \
    gnome-keyring \
    gnome-logs \
    gnome-session \
    gnome-settings-daemon \
    gnome-shell \
    gnome-tweaks \
    gnome-system-monitor \
    gnome-text-editor \
    grilo-plugins \
    gvfs \
    gvfs-mtp \
    loupe \
    malcontent \
    nautilus \
    sushi \
    tecla \
    xdg-desktop-portal-gnome \
    xdg-user-dirs-gtk
    
    systemctl enable gdm.service --root=/mnt
}

install_kde
#install_gnome

systemctl enable fstrim.timer --root=/mnt
systemctl enable NetworkManager.service --root=/mnt

arch-chroot /mnt passwd
read -r -p "Enter username: " user
arch-chroot /mnt useradd -m -G wheel "$user"
arch-chroot /mnt passwd "$user"
