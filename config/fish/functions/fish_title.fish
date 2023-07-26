
function fish_title
	set -U fish_prompt_pwd_dir_length 1
	prompt_pwd

	switch $_
	case 'fish'
		# do nothing
	case '*'
		echo -n ' ' $_
	end
end
