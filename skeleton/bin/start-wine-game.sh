#!/bin/bash
# Run a Wine-based game from an ISO image, 
#	changing screen resolution as needed.
#
# Syntax:
# 	start-wine-game.sh image.iso app.exe
#		- image.iso is the absolute path to the ISO image to run from
#		- app.exe is the MS-DOS absolute path to execute in Wine.

iso_path=$1
app_path=$2
display_mode=${3:-"640x480"}

mapped_drive=~/.wine/dosdevices/${wine_drive}
active_output=$(xrandr -q | sed -n 's/^\(.*\)\( connected.*\)$/\1/p')

# Unmount or otherwise remove any old mounted drive
if mount | grep ${mapped_drive} > /dev/null; then
	umount ${mapped_drive}
fi
if [ -f ${mapped_drive} ]; then
	rm -rf ${mapped_drive}
fi
if [ ! -d ${mapped_drive} ]; then
	mkdir -p ${mapped_drive}
fi

# Mount ISO image to Wine Drive
fuseiso "${iso_path}" ${mapped_drive}

# Change screen to resolution for game...
xrandr --output ${active_output} --mode ${display_mode}

# Start the game in wine...
/usr/bin/wine "${wine_drive}${app_path}"

# Restore to preferred mode/resolution
xrandr --output ${active_output} --auto

# Unmount the ISO Image
fusermount -u ${mapped_drive}
rm -rf ${mapped_drive}
