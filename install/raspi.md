# Raspberry Pi installation

These are my notes on how to install a Raspberry Pi the way I like it.

These are mostly meant for myself, but they might be useful for other people too.

## Image

  * Install image as usual (using `xzcat` and `dd`).
  * Create `ssh` file in bootfs.
  * Set up initial login, see [this answer](https://raspberrypi.stackexchange.com/a/137916/53905) (also see [here](https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/)).
  * Change hostname: modify rootfs/etc/hostname and rootfs/etc/hosts.
  * Optional: configure wifi (if there is no ethernet).
  * Plug into Raspberry Pi and power on.

## Initial setup

  * SSH to device (`ssh raspberrypi.local`)
  * Change password if needed.
  * Copy over backed up home directory if needed (to a separate directory).
    Do this after booting the first time (after the rootfs has been
    expanded).
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
    sudo apt-get install byobu fish neovim git bat htop ripgrep exa picocom golang borgbackup pipewire
    ```
  * Change shell to fish.
  * Configure a few things using raspi-config:
    * Switch to USB audio device.
    * Configure wifi
    * enable console auto-login
    * set timezone
  * Set `PasswordAuthentication no` in `/etc/ssh/sshd_config`
  * Allow pipewire to use high priority (to avoid stuttering):
    ```
    adduser $USER pipewire (doesn't work?)
    ```
  * Create daemon to correct audio on startup at ~/.config/systemd/user/alsa-volume.service:
    ```
    [Unit]
    Description=Set volume level
    
    [Service]
    Type=simple
    ExecStartPre=/bin/sleep 30
    ExecStart=/usr/bin/amixer -c 0 sset PCM '100%'
    
    [Install]
    WantedBy=default.target
    ```
  * Start this daemon by default:
    ```
    systemctl --user enable alsa-volume
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
  * Log out and back in again (to apply group change).
  * Run `docker-compose up -d` in the homeassistant directory.

## Cloud

  * Install dependencies:
    ```
    sudo apt-get install python3-paho-mqtt python3-serial
    ```
  * Create user unit file at ~/.config/systemd/user/cloud-control.service:
    ```
    [Unit]
    Description=Cloud MQTT control
    
    [Service]
    WorkingDirectory=/home/ayke/src/things/cloud
    ExecStart=/home/ayke/src/things/cloud/control.py
    Restart=always
    RestartSec=12
    
    [Install]
    WantedBy=default.target
    ```
  * Enable the daemon at startup:
    ```
    systemctl --user enable cloud-control
    ```

## librespot

  * Install dependencies:
    ```
    sudo apt-get install libasound2-dev
    ```
  * Clone librespot repo
  * `cargo build --features pulseaudio-backend -j1 --release`

## spotifyd

  * Install dependencies:
    ```
    sudo apt-get install libasound2-dev libdbus-1-dev libpulse-dev
    ```
  * Clone spotifyd repo
  * `cargo build --features pulseaudio_backend,dbus_mpris -j1 --release`
  * Create systemd file at ~/.config/systemd/user/spotifyd.service:
    ```
    [Unit]
    Description=Spotify daemon
    
    [Service]
    WorkingDirectory=/home/ayke
    ExecStart=/home/ayke/src/spotifyd/target/release/spotifyd --no-daemon
    Restart=always
    RestartSec=12
    
    [Install]
    WantedBy=default.target
    ```
  * Enable spotifyd at startup:
    ```
    systemctl --user enable spotifyd
    ```

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
