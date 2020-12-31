#!/bin/bash
#
# Run a Wine-based game from an ISO image.
#
# wine-cd-game.sh image.iso app.exe
#
# app_path is relative to the root of the mounted ISO
#
# part of this script runs before X is loaded.
# it loads X (startx) and sets itself as the client to run
# then the other half runs to configure things and start wine

iso_path=$1
app_path=$2
resolution=${3:-"640x480_75"}

wine_drive=d:
if [ -z ${DISPLAY+x} ]; then
	# not in X11
	cd_drive=~/.wine/dosdevices/${wine_drive}

	#imgs="$(dirname "${iso_path}")/$(basename "${iso_path}" .iso)"
	#img=$(ls -1 "${imgs}".{png,jpg,gif} 2> /dev/null | head -1 )
	#fbi --noverbose --fitwidth "${img}"

	# Unmount or otherwise remove any old mounted drive
	if mount | grep ${cd_drive} > /dev/null; then
		umount ${cd_drive}
	fi
	if [ -f ${cd_drive} ]; then
		rm -rf ${cd_drive}
	fi
	if [ ! -d ${cd_drive} ]; then
		mkdir -p ${cd_drive}
	fi

	# Mount ISO image to Wine Drive
	fuseiso "${iso_path}" ${cd_drive}

	ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
	#startx ${ABSOLUTE_PATH} "${wine_drive}${app_path}"
	startx /usr/bin/wine "${wine_drive}${app_path}" -- -config ${resolution}.xconf -background none

	# Unmount the ISO Image
	fusermount -u ${cd_drive}
	rm -rf ${cd_drive}
else
	# This runs when in X11 to change the display and start wine...
	#xrandr --output DVI-I-1 --mode 640x480
	/usr/bin/wine "${1}"
fi
