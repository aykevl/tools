fish_vi_key_bindings
set TERM "xterm-256color"
set fish_greeting

# Misc aliases
alias diff="diff --color=auto"
alias df="df -h"
alias ls="exa"
alias ll="exa -l"
alias egrep="egrep --color=auto"
alias free="free -h"
alias py=python3
alias vim="nvim -p"

# Compiler/binutils aliases
alias avr-objdump="avr-objdump --no-show-raw-insn"
alias objdump="llvm-objdump --x86-asm-syntax=intel"
alias readelf="llvm-readelf"
alias lldb="lldb"
