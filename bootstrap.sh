#!/bin/bash

mame_user=mame
mame_password=mame

# If I am *not* the mame user, create the *mame* user and run as them.
if [ "${USER}" != "${mame_user}" ]; then
	if whiptail --yesno "You are not ${mame_user}. Would you like to create ${mame_user}?" 0 0; then
		echo ""
		echo "Creating ${mame_user}..."
		sudo useradd -mU -s /usr/bin/zsh -G  wheel,uucp,video,audio,storage,games,input ${mame_user}
		sudo chsh -s /usr/bin/zsh ${mame_user}
		echo "${mame_user}:${mame_password}" | sudo chpasswd

		echo ""
		echo "You should now log in as ${mame_user} and re-run this script."
		exit 0
	fi

	if whiptail --yesno "Continue anyway?" 0 0; then
		: # simply continues after the if...
	else
		exit 0
	fi
fi

# Clone the repository from GitHub
git clone https://github.com/stephenhouser/mini-mame.git mini-mame
cd mini-mame
exec bash ./setup-mini-mame.sh
