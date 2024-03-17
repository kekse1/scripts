#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.2
#
# Tiny helper; maybe copy it to /etc/profile.d/fresh.sh
#

_DATE_FORMAT='%s%N'
#_DATE_FORMAT_WITHOUT='%s%N // %Y-%m-%d / %H:%M:%S'

fresh()
{
	if [[ $# -eq 0 ]]; then
		echo " >> Please specify a description for this commit!" >&2
		return
	fi

	_txt="`date +"$_DATE_FORMAT"`"
	_txt="$* [$_txt]"

	echo -e " >> Running commit \`$_txt\`.\n"

	git pull
	git add --all
	git commit -m "$_txt"
	git push
}

