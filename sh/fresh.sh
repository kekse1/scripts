#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.1
#
# Tiny helper; maybe copy it to /etc/profile.d/fresh.sh
#

_GIT_DATE_FORMAT='%s'

fresh()
{
	dir="`git rev-parse --git-dir 2>/dev/null`"

	if [[ $? -ne 0 ]]; then
		echo " >> Not inside a git repository!" >&2
		return 1
	elif [[ $# -eq 0 ]]; then
		echo " >> Please specify a description for this \`git\` commit!" >&2
		return 2
	fi

	_txt="`date +"$_GIT_DATE_FORMAT"`"
	_txt="[$_txt] $*"

	echo -e " >> Git path:\n   \`$(realpath "$dir")\`"
	echo -e " >> Applying \`git\` commit:\n   \`$_txt\`\n"

	git pull
	git add --all
	git commit -m "$_txt"
	git push
}

