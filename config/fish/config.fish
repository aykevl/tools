fish_vi_key_bindings
set TERM "xterm-256color"
set fish_greeting
alias vim="nvim -p"
alias diff="diff --color=auto"
alias df="df -h"
alias free="free -h"
alias egrep="egrep --color=auto"
alias avr-objdump="avr-objdump --no-show-raw-insn"
alias py=python3

# LLVM aliases
alias objdump="llvm-objdump --x86-asm-syntax=intel"
alias readelf="llvm-readelf"
alias lldb="lldb"
