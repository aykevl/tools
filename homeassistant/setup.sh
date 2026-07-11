#!/bin/sh

# this script is run as an init command in the "Advanced SSH & Web Terminal" app in Home Assistant.

set -e

time apk add fish git htop eza moreutils py3-pyserial py3-paho-mqtt # byobu musl-locales

ln -sf /share/tools/config/fish       /root/.config/fish
ln -sf /share/tools/config/gitconfig  /root/.gitconfig
ln -sf /share/tools/config/gitignore  /root/.gitignore
ln -sf /share/tools/config/vimrc      /root/.vimrc
ln -sf /share/tools/config/nvim       /root/.config/nvim
ln -sf /share/tools/config/ssh/config /root/.ssh/config
ln -sf /share/.config/go-librespot    /root/.config

# Daemons
/share/things/cloud/control.py 2>&1 | ts >/root/cloud-log.txt &
/share/spotify/go-librespot/librespot-daemon 2>/root/spotify-log.txt &

echo "Setup finished!"
