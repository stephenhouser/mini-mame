#!/bin/bash
# Script to install mini-mame arcade cabinet with (minimal) Arch Linux.
#
# This assumes you have run the `arch-bootstrap.sh` script prior to this
# and have a working (networked) base system.
#
# 2020/12/31 - Stephen Houser <stephenhouser@gmail.com>
#

# consider packages
# from libretro
# bluez-libs-5.55-1 bluez-libs-5.55-1  enet-1.3.16-1  fmt-7.1.3-1  libzip-1.7.3-1  mbedtls-2.16.7-1 miniupnpc-2.1.20191224-3  minizip-1:1.2.11-4  snappy-1.1.8-2

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
	xorg xorg-xinit \
	xf86-video-ati xf86-video-amdgpu xf86-video-intel xf86-video-nouveau xf86-video-fbdev \
	xorg-fonts-misc xterm xorg-mkfontdir \
	lxde \
	alsa-utils pulseaudio \
	fuseiso

echo ""
echo "Unmute ALSA Audio..."
amixer sset Master unmute
amixer sset Master '100%'
amixer sset Speaker unmute
amixer sset Speaker '100%'
amixer sset Headphone unmute
amixer sset Headphone '100%'

# lwm				-- super tiny window manager that only managers windows!
# xorg-twm			-- minimal window manager
# fbdia				-- display images on the console framebuffer
#	fbdia

# Was experimenting with CDEmu. Don't seem to need it (yet)
# vhba-module 	-- emulates SCSI devices (for CDEmu)
# cdemu-clinet	-- emulates real CD drives with ISO images
#pacman --noconform -S cdemu-client vhba-module
#systemctl enable cdemu-daemon.service


# Mutliple Arcade Machine Emulator via RetroArch
# mame				-- the emulator; use this just to have a mame exe around
# retroarch			-- frontend and CLI for libretro and launching cores
# libretro-core-info	-- needed by retroarch to run cores
# libretro-overlays		-- graphic overlays
# retroarch-assets-xmb	-- graphic elements of retroarch UI

# Install RetroArch -- really for libretro and the "cores" that will allow
# running earlier versions of MAME arcade games. This is just a very
# basic install as I don't use the frontend of RetroArch, I just want the
# ability to use it to launch the libretro-mame games and get the nice
# benefits of libretro.
sudo pacman -S retroarch libretro-core-info libretro-overlays retroarch-assets-xmb

# Run one time to get the template configuration setup
sudo retroarch

cat > ~/.config/retroarch/retroarch.cfg << EOF
audio_filter_dir = "/usr/lib/retroarch/filters/audio"
video_filter_dir = "/usr/lib/retroarch/filters/video"
libretro_info_path = "/usr/share/libretro/info"

libretro_directory = "~/.config/retroarch/cores"
assets_directory = "~/.config/retroarch/assets"
log_dir = "~/.config/retroarch/logs"
video_shader_dir = "~/.config/retroarch/shaders"
cheat_database_path = "~/.config/retroarch/cheats"
cursor_directory = "~/.config/retroarch/database/cursors"
input_remapping_directory = "~/.config/retroarch/config/remaps"
savefile_directory = "~/.config/retroarch/saves"
savestate_directory = "~/.config/retroarch/states"
screenshot_directory = "~/.config/retroarch/screenshots"
system_directory = "~/.config/retroarch/system"
thumbnails_directory = "~/.config/retroarch/thumbnails"
video_layout_directory = "~/.config/retroarch/layouts"

content_database_path = "~/.config/retroarch/database/rdb"
content_favorites_path = "~/.config/retroarch/content_favorites.lpl"
content_history_path = "~/.config/retroarch/content_history.lpl"
content_image_history_path = "~/.config/retroarch/content_image_history.lpl"
content_music_history_path = "~/.config/retroarch/content_music_history.lpl"
content_video_history_path = "~/.config/retroarch/content_video_history.lpl"
core_updater_buildbot_assets_url = "http://buildbot.libretro.com/assets/"
core_updater_buildbot_cores_url = "http://buildbot.libretro.com/nightly/linux/x86_64/latest/"

libretro_log_level = "1"
menu_show_core_updater = "true"
config_save_on_exit = "true"
autosave_interval = "600"
video_threaded = "true"
audio_driver = "alsa"
audio_out_rate = "48000"
EOF

# Download MAME 2000, MAME 2003+, and MAME 2010 cores for RetroARch / LibRetro
mkdir -p ~/.config/retroarch/cores
cd ~/.config/retroarch/cores

function download_core() {
	rm -f ${1}
	wget http://buildbot.libretro.com/nightly/linux/x86_64/latest/${1}_libretro.so.zip && unzip ${1}_libretro.so.zip && rm ${1}_libretro.so.zip
}

download_core mame2000
download_core mame2003
download_core mame2003_plus
download_core mame2010
#download_core mame2015	# not available in latest build (url above)
#download_core mame2016 # not available in latest build (url above)
#download_core mame		# not available in latest build (url above)

# for Kids games... testing
download_core scummvm

echo ""
echo "Install AUR source packages..."
mkdir -p src

# Install/build MAME from AUR -- USE SPECIFIC VERSION 0.227
echo ""
echo "Install MAME (arcade games)..."
sudo pacman -S mame
# git clone https://aur.archlinux.org/mame-git.git ~/src/mame
# cd ~/src/mame
# sed -i 's|https://github.com/mamedev/mame.git|https://github.com/mamedev/mame.git#tag=mame0227|' PKGBUILD
# makepkg -si
# cd ..

# Install/build attract mode from AUR
# Uses git://github.com/DavidGriffith/daphne.git
echo ""
echo "Install Daphne (laser disc games)..."
git clone https://aur.archlinux.org/daphne-git.git ~src/daphne
cd ~/src/daphne
makepkg -si
cd ~

# Install/build attract mode from AUR
echo ""
echo "Install Attract Mode (menu frontend for launching games)..."
git clone https://aur.archlinux.org/attract-git.git ~/src/attract
cd ~src/attract
makepkg -si
cd ~


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

# Using old Kids-MAME Windows directory...
# Mount Windwos partition to /media/windows
mkdir -p /media/windows
echo "# Mount WindowsXP Partition" >> /etc/fstab
echo "/dev/sda1		/media/windows		ntfs	ro	0 2" >> /etc/fstab

echo ""
echo "*** Windows Games ***"
echo ""
echo "You still need need to run `wine` and `winecfg` under X to configure Wine"
echo "	startx /usr/bin/wine progman"
echo "	startx /usr/bin/winecfg"
echo "and install any packages it asks to install."
echo ""


# Copy in dot files *after* everything else so we can overlay our
# configs onto the default ones created above...
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
