#!/bin/bash
# Script to install mini-mame arcade cabinet with (minimal) Arch Linux.
#
# This assumes you have run the `arch-bootstrap.sh` script prior to this
# and have a working (networked) base system.
#
# 2020/12/31 - Stephen Houser <stephenhouser@gmail.com>
#

# Mount Windwos partition to /media/windows
mkdir -p /media/windows

echo "# Mount WindowsXP Partition"
echo "/dev/sda1		/media/windows		ntfs	ro	0 2" >> /etc/fstab

# Enable multilib to get wine
cp /etc/pacman.conf /etc/pacman.conf.bak
awk '/^#\[multilib\]$/ {sub("#",""); print; getline; sub("#",""); print; next;} 1' < /etc/pacman.conf.bak > /etc/pacman.conf

# Full system update and upgrade to latest rolling release!
pacman -Sy
pacman -Syy
pacman -Syu

# Base system tools
# xorg				-- X windows
# xorg-xinit		-- xinit and startx
# xterm				-- you need some sort of terminal
# alsa-utils		-- audio drivers
# lib32-alsa-lib	-- for 32-bit windows
# pulseaudio		-- for more complex than alsa
# lib32-libpulse	-- for 32-bit windows
# fuseiso			-- Enable user mounting of ISO images
# fbdia				-- display images on the console framebuffer
pacman --noconfirm -S \
	xorg xorg-xinit xterm \
	alsa-utils lib32-alsa-lib \
	pulseaudio lib32-libpulse \
	fuseiso \
	fbdia

# Microsoft Windows things...
# wine				-- not an emulator of windoes
# winetricks		-- for setting things up easier
pacman --noconfirm -S wine winetricks

# Mutliple Arcade Machine Emulator
# mame				-- the emulator
pacman --noconfirm -S mame

# Was experimenting with CDEmu. Don't seem to need it (yet)
# vhba-module 	-- emulates SCSI devices (for CDEmu)
# cdemu-clinet	-- emulates real CD drives with ISO images
#pacman --noconform -S cdemu-client vhba-module
#systemctl enable cdemu-daemon.service

