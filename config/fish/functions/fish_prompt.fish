
# vim: set noet:
#
# Set the default prompt command.

function fish_prompt --description "Write out the prompt"
	# Just calculate this once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

	set -U fish_prompt_pwd_dir_length 0
	set -l user "\033[1;38;5;77m$USER\033[00m"
	set -l host "\033[1;38;5;220m$__fish_prompt_hostname\033[00m"
	set -l root "\033[31mroot\033[00m"
	set -l pwd (prompt_pwd)
	set -l pwd "\033[1;38;5;39m$pwd\033[00m"
	set -l prefix ""

	switch $USER
		case 'ayke'
			set user root
	end

	if set -q SSH_TTY
		switch $USER
			case 'ayke'
				set prefix "$host"
			case '*'
				set prefix "$user@$host"
		end
	else
		switch $USER
			case 'ayke'
				set prefix ""
			case '*'
				set prefix "$user"
		end
	end

	# Like prompt_pwd, but without shortening the parent directories.
	echo -en "\n$prefix$pwd"
	#switch $PWD
	#case "/home/$USER"
	#	echo -n "~"
	#case "/home/$USER/*"
	#	echo -n "~...$PWD"
	#case '*'
	#	echo -n "$PWD"
	#end

	if test "$fish_key_bindings" = "fish_vi_key_bindings"
		switch $fish_bind_mode
			case default visual
				set_color --bold red
			case insert
				set_color normal
			case replace-one
				set_color yellow
		end
	end
	echo -n '$'

	set_color normal
	echo -n ' '
end
