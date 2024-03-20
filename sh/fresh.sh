#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.0
#
# Tiny helper; maybe copy it to /etc/profile.d/fresh.sh
#

_DATE_FORMAT='%s'
#_DATE_FORMAT='%s%N'
#_DATE_FORMAT_WITHOUT='%s%N // %Y-%m-%d / %H:%M:%S'

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

	_txt="`date +"$_DATE_FORMAT"`"
	_txt="[$_txt] $*"

	echo -e " >> Applying \`git\` commit:\n   \`$_txt\`.\n"

	git pull
	git add --all
	git commit -m "$_txt"
	git push
}

