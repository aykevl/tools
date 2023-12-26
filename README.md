# Dotfiles / configuration / installation notes / scripts

Personal repository for some tools and configurations I use. Use them at your own risk.

License: public domain. Feel free to do whatever you want with this code.

## Apple keyboard with Windows/Linux layout

On Linux:
  * Enable Settings -> Advanced -> Ctrl position -> Swap Right Win with Right Ctrl
  * Symlink config/xkb -> ~/.config/xkb
  * Edit (or create) `/etc/modprobe.d/hid_apple.conf` to contain `options hid_apple fnmode=2 swap_opt_cmd=1`, then update initramfs (run `sudo mkinitcpio -P` on Arch).

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

## Windows setup

Windows Terminal:
  * [Use Git Bash](https://www.youtube.com/watch?v=zM9Mb-otqww).
  * Configure keyboard shortcuts, by adding this to the settings.json file (in the `actions` list):
    ```javascript
    // globalSummon has tabs whereas quake mode doesn't
    { "command": { "action": "globalSummon", "name": "hotkey", "dropdownDuration": 0 }, "keys": "f9" },
    //{ "command": { "action": "newTab" }, "keys": "ctrl+shift+n" }, // doesn't work
    { "command": "nextTab", "keys": "ctrl+pgdn" },
    { "command": "prevTab", "keys": "ctrl+pgup" },
    { "command": { "action": "moveTab", "direction": "forward" }, "keys": "ctrl+shift+pgdn" },
    { "command": { "action": "moveTab", "direction": "backward" }, "keys": "ctrl+shift+pgup" }
    ```
