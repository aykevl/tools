fish_vi_key_bindings
set TERM "xterm-256color"
set fish_greeting

# ls-related aliases
alias ls="exa --group-directories-first"
alias la="exa --group-directories-first -la"
alias ll="exa --group-directories-first -l"
alias tree="exa --group-directories-first --tree"

# Compiler/binutils aliases
alias avr-objdump="avr-objdump --no-show-raw-insn"
alias objdump="llvm-objdump --x86-asm-syntax=intel"
alias readelf="llvm-readelf"
alias lldb="lldb"

# Misc aliases
alias diff="diff --color=auto"
alias df="df -h"
alias egrep="egrep --color=auto"
alias free="free -h"
alias py=python3
alias vim="nvim -p"
