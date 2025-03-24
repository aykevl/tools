
# Install RPMFusion
See https://docs.fedoraproject.org/en-US/quick-docs/rpmfusion-setup/

# Basic tools

```
sudo dnf install fish vim neovim eza golang bat htop ripgrep picocom borgbackup distrobox git-delta tig pwgen optipng unzip
```

# Graphic tools

```
sudo dnf install vlc yakuake quassel-client chromium inkscape gimp meld virt-manager
```

# TinyGo

```
sudo dnf install llvm-devel lld-libs lld clang-devel gcc-c++ cmake ninja-build glfw-devel libXxf86vm-devel gdb openocd binaryen qemu-system-arm qemu-user qemu-system-riscv wabt
```

# set-theme dependencies

```
sudo dnf install python3-pydbus python3-astral oxygen-cursor-themes
```

# install Widevine

```
sudo dnf install widevine-installer
sudo widevine-installer
```

# Install vscode

See: https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions

# Enable ADB

```
sudo dnf install android-tools
cp /usr/share/doc/android-tools/51-android.rules /etc/udev/rules.d/
```

