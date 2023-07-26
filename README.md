# Dotfiles / configuration / installation notes / scripts

Personal repository for some tools and configurations I use. Use them at your own risk.

License: public domain. Feel free to do whatever you want with this code.

## Apple keyboard with Windows/Linux layout

On Linux:
  * Enable Settings -> Advanced -> Ctrl position -> Swap Right Win with Right Ctrl
  * Symlink config/xkb -> ~/.config/xkb
  * Edit (or create) `/etc/modprobe.d/hid_apple.conf` to contain `options hid_apple fnmode=2 swap_opt_cmd=1`

On MacOS:
  * Use [Karabiner](https://karabiner-elements.pqrs.org/) to change keyboards:
    * Change modifier keys for the Apple internal keyboard so it works like a PC keyboard:
      - `left_command` -> `left_option`
      - `left_option` -> `left_command`
      - `right_command` -> `right_option`
      - `right_option` -> `right_control`
    * Add complex modifications:
      - Map ctrl-shift + C/V to copy/paste in term (but change JSON to also copy on right shift)
      - Windows-ify Key Mappings on Mac OS (except Alt-F4)
      - Open a Terminal window with Ctrl-Alt-T (change command in JSON file to use iTerm instead)
      - Ctrl/Option/Command + Tab Change
  * Modify Code keyboard shortcuts for Ctrl-P.
  * Add some system changes for text movement etc, by symlinking `~/Library/KeyBindings/DefaultKeyBinding.dict`.
  * Change Spotlight keyboard shortcut to Option-Space (to preserve previous key):
    Settings -> Keyboard -> Keyboard Shortcuts -> Spotlight
