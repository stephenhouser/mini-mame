# Mini-MAME

Configuration and setup for a "retro arcade computer", other wise known as _Kids MAME 2_ or now _Mini-MAME_. This is a rebuild of my original [Kids MAME 1](https://stephenhouser.com/kids_mame_1/) which hosted Arcade games and a selection of PC (Windows) games for my children.

## Key Components

* [Attract Mode](http://attractmode.org) as the graphical front-end or game chooser.
* [RetroArch](https://retroarch.com) and [LibRETRO](https://www.libretro.com) for running a number of the games with control configurations and features.
* X Windows as `wine` and `attract mode` need X to do their thing
* [Wine](https://winehq.org) to enable running Microsoft Windows based games.
* [Daphne](https://daphne-emu.com) for running Laser Disc based games (Space Ace)
* [Arch Linux](https://archlinux.org) as the base operating system.

## Graphical Front-End

_Attract Mode_ is an attractive front-end that is small, easy to navigate, and only loosely documented. Which makes it perfect for my use. Oh, it's cross platform as well so I can use it on Linux.

## Running Gamess

_RetroArch_ and _LibRETRO_ make running most arcade games very simple. While _RetroArch_ has a complete front-end, I find it unsuitable to a traditional arcade style machine with joystick and keys. So, I don't use that part. The part where it can run older MAME ROMs (0.37b5) and where it provides game recording, pause, rewind, and fastforward are really the features being used.

_LibRETRO_ refers to the game engines that it can run as _cores_. The following are _cores_ I've installed here.

* MAME 2000 -- runs MAME 0.37b5 ROMs (includes 95% of  of my favorite classic American arcade games)
* MAME 2003 -- runs MAME 0.78 ROMs (includes more of the classic American arcade experience)
* MAME 2003 Plus -- runs MAME 0.78+ ROMS (includes 99% of my favorite classic American arcade)
* ScummVM -- runs a number of the "Kids Games" from Humougous Entertainment.

### Other Games

The `wine-iso` script mounts and executes a number of other _Windows_ based games my kids lived to play. It uses `fuseiso` and `wine` to accomplish this.

## Operating System

_Arch Linux_ provides a lightweight configurable base without a lot of extra cruft that I don't want on a mostly-disconnected computer. No data collection, Internet updating when you don't want it, or strange _user analytics_ going on in the background.

## Setting Up

1. _Arch Linux_ should already be installed. Check the [Arch Bootstrap](https://github.com/stephenhouser/arch-bootstrap) project to get that done.

2. Either create the `mame` or `arcade` user by hand or use the included `bootstrap.sh` to do that.

3. As the `mame` or `arcade` user, run `bootstrap.sh` to install and configure most of the stuff needed. Perferably do this _at the console_ as some of the steps might open up a window and require attention. All this stuff is after all designed to be run at the console.

4. Run `startx /usr/bin/wine progman` and `startx /usr/bin/winecfg` get wine to build it's directory structure

Scripts for setting up mini-mame arcade machine with Arch Linux

* `bootstrap.sh` to create the `mame` account if you don't have it already
* `bootstrap.sh` to pull the repo and run `setup-mini-mame.sh` which installs everything

