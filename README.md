# Dotfiles / configuration / installation notes / scripts

Personal repository for some tools and configurations I use. Use them at your own risk.

License: public domain. Feel free to do whatever you want with this code.

## Apple keyboard with Windows/Linux layout

On Linux:
  * Enable Settings -> Advanced -> Ctrl position -> Swap Right Win with Right Ctrl
  * Symlink config/xkb -> ~/.config/xkb
  * Edit (or create) `/etc/modprobe.d/hid_apple.conf` to contain `options hid_apple fnmode=2 swap_opt_cmd=1`

On MacOS:
  * Switch around modifier keys in keyboard settings
  * Use Karabiner to change various keyboard shortcuts
  * Modify Code keyboard shortcuts for Ctrl-P etc
