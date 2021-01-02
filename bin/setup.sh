#!/bin/bash
# Script to install mini-mame arcade cabinet with (minimal) Arch Linux.
#
# This assumes you have run the `arch-bootstrap.sh` script prior to this
# and have a working (networked) base system.
#
# 
#
# 2020/12/31 - Stephen Houser <stephenhouser@gmail.com>
#

mame_user=mame
mame_password=mame

skeleton_files=".xinitrc .screenrc .attract .mame bin kids-games"

# Get ourselves root via sudo if we are not running with sudo already...
if [[ "$EUID" != 0 ]]; then
	ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
	sudo ${ABSOLUTE_PATH}
	exit 1
fi
# Do your sudo stuff here. Password will not be asked again due to caching.

# Enable multilib to get wine
echo ""
echo "Updating system... (adding multilib for Wine)..."
cp /etc/pacman.conf /etc/pacman.conf.bak
awk '/^#\[multilib\]$/ {sub("#",""); print; getline; sub("#",""); print; next;} 1' < /etc/pacman.conf.bak > /etc/pacman.conf

# Full system update and upgrade to latest rolling release!
pacman -Syy			# update package indicies
pacman -Syu			# upgrade the packages.

# Base system tools
# xorg				-- X windows
# xorg-xinit		-- xinit and startx
# xorg-fonts-misc	-- we need some basic fonts for X11
# xterm				-- you need some sort of terminal
# alsa-utils		-- audio drivers
# lib32-alsa-lib	-- for 32-bit windows
# pulseaudio		-- for more complex than alsa
# lib32-libpulse	-- for 32-bit windows
# fuseiso			-- Enable user mounting of ISO images
# fbdia				-- display images on the console framebuffer
pacman --noconfirm -S \
	xorg xorg-xinit xorg-fonts-misc xterm \
	alsa-utils lib32-alsa-lib \
	pulseaudio lib32-libpulse \
	fuseiso

#	fbdia

# Was experimenting with CDEmu. Don't seem to need it (yet)
# vhba-module 	-- emulates SCSI devices (for CDEmu)
# cdemu-clinet	-- emulates real CD drives with ISO images
#pacman --noconform -S cdemu-client vhba-module
#systemctl enable cdemu-daemon.service

# Microsoft Windows things...
# wine				-- not an emulator of windoes
# winetricks		-- for setting things up easier
pacman --noconfirm -S wine winetricks
# to get a cmd prompt ... $ wineconsole cmd

# Mutliple Arcade Machine Emulator
# mame				-- the emulator
pacman --noconfirm -S mame

# Install/build MAME from AUR
#git clone https://aur.archlinux.org/mame-git.git mame
#cd mame
#makepkg -si
#cd ..

# Install/build attract mode from AUR
#git clone https://aur.archlinux.org/attract-git.git
#cd attract
#makepkg -si
#cd ..

echo ""
echo "Setting MAME (autologin) account..."
# Add user account
useradd -mU -s /usr/bin/zsh -G  wheel,uucp,video,audio,storage,games,input ${mame_user}
chsh -s /usr/bin/zsh ${mame_user}
echo "${mame_user}:${mame_password}" | chpasswd

# Copy in dot files
echo ""
echo "Setup ${mame_user} dot files..."
for f in ${skeleton_files}; do
	cp -Rv ${f} /home/${mame_user}/
	chown -R ${mame_user}:${mame_user} $f
done

cat >> /home/${mame_user}/.zshrc << EOF
export EDITOR='vim'
export PAGER=`which less`
#export LESS="-eFRX -x4"
#export MORE="-eFRX -x4"
#export MANPAGER="$PAGER -isX"

alias vi=vim
alias ls='ls --color=auto'

if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
fi
EOF

# Enable automatic login to the console
# https://wiki.archlinux.org/index.php/Getty
echo ""
echo "Enable auto-login as ${mame_user}..."
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat >> /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin ${mame_user} --noclear %I $TERM
EOF

echo ""
echo "done."


# Using old Kids-MAME Windows directory...
# echo ""
# echo "Setting MAME (autologin) account..."
# # Mount Windwos partition to /media/windows
# mkdir -p /media/windows

# echo "# Mount WindowsXP Partition" >> /etc/fstab
# echo "/dev/sda1		/media/windows		ntfs	ro	0 2" >> /etc/fstab
