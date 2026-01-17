
# vim: set noet:
#
# Set the default prompt command.

function fish_prompt --description "Write out the prompt"
	set -U fish_prompt_pwd_dir_length 0
	set -l user "\033[1;38;5;77m$USER\033[00m"
	set -l host "\033[1;38;5;220m$hostname\033[00m"
	set -l container "📦 \033[1;38;5;208m$CONTAINER_ID\033[00m"
	set -l root "\033[31mroot\033[00m"
	set -l pwd "\033[1;38;5;39m$(prompt_pwd)\033[00m"
	set -l prefix ""

	switch $USER
		case 'ayke'
			set user root
	end

	if set -q SSH_TTY
		# TODO: add container ID with different color
		set prefix "$host"
	else if set -q CONTAINER_ID
		set prefix "$container"
	end

	# add username if needed
	if [ "$USER" != "ayke" ]
		if [ "$prefix" = "" ]
			set prefix "$user"
		else
			set prefix "$user@$prefix"
		end
	end

	# Like prompt_pwd, but without shortening the parent directories.
	echo -en "\n$prefix$pwd"

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
