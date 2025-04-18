fish_vi_key_bindings
set fish_greeting

# OS specific
switch (uname)
	case Darwin
		source ~/.profile
end

# ls-related aliases
if test -e /bin/exa
	alias eza="exa"
end
alias ls="eza --group-directories-first"
alias la="eza --group-directories-first -la"
alias ll="eza --group-directories-first -l"
alias tree="eza --group-directories-first --tree"

# Compiler/binutils aliases
alias avr-objdump="avr-objdump --no-show-raw-insn"
alias objdump="llvm-objdump --x86-asm-syntax=intel"
alias readelf="llvm-readelf"
alias lldb="lldb"

# Cat/bat stuff
if test -e /bin/batcat
	# Debian uses batcat instead of bat
	alias cat="batcat -pp --theme=ansi"
else
	alias cat="bat -pp --theme=ansi"
end

# Misc aliases
alias diff="delta --color-only --paging=never"
alias df="df -h"
alias du="du -h"
alias egrep="egrep --color=auto"
alias free="free -h"
alias py=python3
alias vi="nvim -p"
alias vim="nvim -p"
alias rg='rg --sort-files'
alias gg='git grep'
alias top='htop'
alias beep='aplay -q /usr/share/sounds/speech-dispatcher/pipe.wav'
