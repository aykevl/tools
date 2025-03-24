
# Debian basic tools:

```
sudo apt-get install fish vim neovim exa golang bat htop ripgrep tig
```

# TinyGo

```
echo 'deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-18 main' | sudo tee /etc/apt/sources.list.d/llvm.list
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
sudo apt-get update
sudo apt-get install clang-18 libclang-18-dev lld-18 llvm-18-dev
sudo apt-get install qemu-user-static
```
