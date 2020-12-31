#!/bin/bash
#
# Script to install mini-mame arcade cabinet

# Mount Windwos partition to /media/windows
mkdir -p /media/windows

echo "# Mount WindowsXP Partition"
echo "/dev/sda1		/media/windows		ntfs	ro	0 2" >> /etc/fstab

# Enable multilib to get wine
cp /etc/pacman.conf /etc/pacman.conf.bak
awk '/^#\[multilib\]$/ {sub("#",""); print; getline; sub("#",""); print; next;} 1' < /etc/pacman.conf.bak > /etc/pacman.conf

# Update package listing
pacman -Sy

# Allow mame user to mount ISO images with FUSE
# vhba-module 	-- emulates SCSI devices (for CDEmu)
# cdemu-clinet	-- emulates real CD drives with ISO images
pacman --noconfirm -S fuseiso cdemu-client vhba-module
systemctl enable cdemu-daemon.service

# Install audio things
pacman --noconfirm -S alsa-utils pulseaudio lib32-alsa-lib lib32-libpulse

# Install XWindows things
pacman --noconfirm -S xorg xorg-xinit xterm 

# Install MS-Windows things
pacman --noconfirm -S wine winetricks

# View images at the console
pacman --noconfirm -S fbida

# Mutliple Arcade Machine Emulator
pacman --noconfirm -S mame