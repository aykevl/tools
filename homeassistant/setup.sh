#!/bin/sh

# this script is run as an init command in the "Advanced SSH & Web Terminal" app in Home Assistant.

# Don't exit due to an invalid command, it prevents the HA app from starting.
#set -e

time apk add fish git htop eza moreutils py3-pyserial py3-paho-mqtt # byobu musl-locales

ln -sf /share/tools/config/fish       /root/.config/fish
ln -sf /share/tools/config/gitconfig  /root/.gitconfig
ln -sf /share/tools/config/gitignore  /root/.gitignore
ln -sf /share/tools/config/vimrc      /root/.vimrc
ln -sf /share/tools/config/nvim       /root/.config/nvim
ln -sf /share/tools/config/ssh/config /root/.ssh/config
ln -sf /share/.config/go-librespot    /root/.config/go-librespot
ln -sf /share/.config/htop            /root/.config/htop
ln -sf /share/.local                  /root/.local

# Daemons
while true; do /share/things/cloud/control.py 2>&1 | ts >>/root/cloud-log.txt; sleep 60; done &
while true; do /share/spotify/go-librespot/librespot-daemon >>/root/spotify-log.txt 2>&1; sleep 60; done &
/share/tools/homeassistant/spotify-restart.sh 2>&1 | ts >/root/spotify-restart.txt &

echo "Setup finished!"
