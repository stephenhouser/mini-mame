#!/bin/bash
# Script to install mini-mame arcade cabinet with (minimal) Arch Linux.
#
# This assumes you have run the `arch-bootstrap.sh` script prior to this
# and have a working (networked) base system.
#
# 2020/12/31 - Stephen Houser <stephenhouser@gmail.com>
#

mame_user=mame
mame_password=mame

# If I am *not* the mame user, create the *mame* user and run as them.
if [ "${USER}" != "${mame_user}" ]; then
	if $(whiptail --yesno "You are not ${mame_user}. Continue anyway?" 0 0); then
		:	# simply continues after the if...
	else
		exit 0
	fi
fi

# Get ourselves root via sudo if we are not running with sudo already...
# if [[ "$EUID" != 0 ]]; then
# 	ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
# 	sudo ${ABSOLUTE_PATH}
# 	exit 1
# fi

# Enable multilib to get wine
echo ""
echo "Updating system... (adding multilib for Wine)..."
sudo cp /etc/pacman.conf /etc/pacman.conf.bak
awk '/^#\[multilib\]$/ {sub("#",""); print; getline; sub("#",""); print; next;} 1' < /etc/pacman.conf > /tmp/pacman.conf.$$
sudo mv /tmp/pacman.conf.$$ /etc/pacman.conf

# Full system update and upgrade to latest rolling release!
sudo pacman -Syy			# update package indicies
sudo pacman -Syu			# upgrade the packages.

# Base system tools
# xorg				-- X windows
# xorg-xinit		-- xinit and startx
# xorg-fonts-misc	-- we need some basic fonts for X11
# xterm				-- you need some sort of terminal
# alsa-utils		-- audio drivers
# pulseaudio		-- for more complex than alsa
# fuseiso			-- Enable user mounting of ISO images
# lxde				-- lightweight window manager
sudo pacman --noconfirm -S \
	xorg xorg-xinit xorg-fonts-misc xterm lxde \
	alsa-utils pulseaudio \
	fuseiso

echo ""
echo "Unmute ALSA Audio..."
amixer sset Master unmute
amixer sset Master '75%'
amixer sset Speaker unmute
amixer sset Speaker '75%'
amixer sset Headphone unmute
amixer sset Headphone '75%'

# lwm				-- super tiny window manager that only managers windows!
# xorg-twm			-- minimal window manager
# fbdia				-- display images on the console framebuffer
#	fbdia

# Was experimenting with CDEmu. Don't seem to need it (yet)
# vhba-module 	-- emulates SCSI devices (for CDEmu)
# cdemu-clinet	-- emulates real CD drives with ISO images
#pacman --noconform -S cdemu-client vhba-module
#systemctl enable cdemu-daemon.service

# Microsoft Windows things...
# https://wiki.archlinux.org/index.php/Wine
# wine				-- not an emulator of windoes
# winetricks		-- for setting things up easier
# wine-mono			-- .NET framework
# wine-gecko		-- Internet Explorer widgets
# lib32-alsa-lib	-- for 32-bit windows
# lib32-libpulse	-- for 32-bit windows
# lib32-mpg123		-- MP3 for wine
# lib32-giflib		-- GIF for wine
# lib32-libpng		-- PNG for wine
sudo pacman --noconfirm -S \
	wine winetricks wine-mono wine-gecko \
	lib32-alsa-lib lib32-libpulse \
	lib32-mpg123 lib32-giflib lib32-libpng

# to get a cmd prompt ... $ wineconsole cmd
# winetricks windowscodecs

# Copy in dot files
echo ""
echo "Setup dot files..."
rsync -avz ./skeleton/ ${HOME}

cat >> ${HOME}/.zshrc << EOF
export EDITOR='vim'
export PAGER=`which less`
#export LESS="-eFRX -x4"
#export MORE="-eFRX -x4"
#export MANPAGER="$PAGER -isX"

alias vi=vim
alias ls='ls --color=auto'

if [ -d "${HOME}/bin" ] ; then
        PATH="${HOME}/bin:$PATH"
fi
EOF

echo ""
echo "Setting autologin account..."
# Enable automatic login to the console
# https://wiki.archlinux.org/index.php/Getty
echo ""
echo "Enable auto-login as ${USER}..."
cat >> /tmp/override.conf.$$ << EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin ${USER} --noclear %I $TERM
EOF
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo mv /tmp/override.conf.$$ /etc/systemd/system/getty@tty1.service.d/override.conf

echo ""
echo "You still need need to run `wine` and `winecfg` under X to configure Wine"
echo "	startx /usr/bin/wine progman"
echo "	startx /usr/bin/winecfg"
echo "and install any packages it asks to install."
echo ""

# Mutliple Arcade Machine Emulator
# mame				-- the emulator
# pacman --noconfirm -S mame

# Install/build MAME from AUR
# git clone https://aur.archlinux.org/mame-git.git mame
# cd mame
# makepkg -si
# cd ..

# Install/build attract mode from AUR
# git clone https://aur.archlinux.org/attract-git.git
# cd attract
# makepkg -si
# cd ..

# Using old Kids-MAME Windows directory...
# echo ""
# echo "Setting MAME (autologin) account..."
# # Mount Windwos partition to /media/windows
# mkdir -p /media/windows

# echo "# Mount WindowsXP Partition" >> /etc/fstab
# echo "/dev/sda1		/media/windows		ntfs	ro	0 2" >> /etc/fstab
