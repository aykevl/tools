# Raspberry Pi installation

These are my notes on how to install a Raspberry Pi the way I like it.

These are mostly meant for myself, but they might be useful for other people too.

## Image

  * Install image as usual (using `xzcat` and `dd`).
  * Copy over backed up home directory if needed (to a separate directory).
  * Create `ssh` file in bootfs.
  * Set up initial login, see [this answer](https://raspberrypi.stackexchange.com/a/137916/53905) (also see [here](https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/)).
  * Change hostname: modify bootfs/hostname and bootfs/hosts.
  * Optional: configure wifi (if there is no ethernet).
  * Plug into Raspberry Pi and power on.

## Initial setup

  * SSH to device (`ssh raspberrypi.local`)
  * Change password if needed.
  * Create `/usr/local/bin/up`:
    ```sh
    #!/bin/sh
    
    set -e
    apt update
    apt dist-upgrade
    apt autoremove --purge
    ```
  * Install updates using `sudo up`.
  * Install basic tools:
    ```
    sudo apt-get install byobu fish neovim git bat htop ripgrep exa picocom golang borgbackup
    ```
  * Configure a few things using raspi-config:
    * Switch to USB audio device.
    * Configure wifi
  * Allow pipewire to use high priority (to avoid stuttering):
    ```
    adduser $USER pipewire
    ```

## Automatic backups

  * Configure crontab to run backups:
    ```
    35  7  *   *   *     backup
    ```

## Home assistant

  * Install dependencies:
    ```
    sudo apt-get install docker-compose mosquitto
    ```
  * Add myself to the docker group:
    ```
    sudo adduser ayke docker
    ```
  * Run `docker-compose up -d` in the homeassistant directory.

## librespot

  * Install dependencies:
    ```
    sudo apt-get install libasound2-dev
    ```
  * Clone librespot repo
  * `cargo build --features pulseaudio-backend -j1 --release`

## librespot-java

  * Install dependencies:
    ```
    sudo apt-get install default-jre-headless
    ```
  * Create the following file at `/etc/systemd/system/librespot-java.service`:
    ```
    # Based on: https://github.com/Spotifyd/spotifyd/blob/master/contrib/spotifyd.service
    [Unit]
    Description=librespot-java
    Wants=sound.target
    After=sound.target
    Wants=network-online.target
    After=network-online.target
    Wants=systemd-networkd-wait-online.service
    After=systemd-networkd-wait-online.service
    Wants=avahi-daemon.service
    After=avahi-daemon.service
    
    [Service]
    WorkingDirectory=/home/ayke/librespot-java
    ExecStart=java -jar librespot-player-1.6.3.jar
    User=ayke
    Restart=always
    RestartSec=12
    
    [Install]
    WantedBy=default.target
    ```
  * Enable the service: `sudo systemctl enable librespot-java`

## Bluetooth audio receiver

Loosely based on: https://www.collabora.com/news-and-blog/blog/2022/09/02/using-a-raspberry-pi-as-a-bluetooth-speaker-with-pipewire-wireplumber/

  * Install dependencies:
    ```
    sudo apt-get install pipewire wireplumber libspa-0.2-bluetooth python3-dbus
    ```
  * Add file `/etc/machine-info` with the following contents:
    ```
    PRETTY_HOSTNAME="Raspberry Pi"
    ```
  * Change `/etc/bluetooth/main.conf`:
    * `DiscoverableTimeout=0`
  * In `bluetoothctl`, run:
    * `discoverable on`
  * TODO: find a way to avoid audio stuttering.
    (This probably means using an external Bluetooth adapter, the one built in to the Pi 3B isn't usable for music because of frequent data corruption: the Bluetooth UART isn't using hardware flow control).
