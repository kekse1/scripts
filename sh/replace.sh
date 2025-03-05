#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.2
#

_regex="$*"

if [[ -z "$_regex" ]]; then
	echo " >> Please argue with \`sed\` compatible regular expression!" >&2
	exit 1
fi

traverse()
{
	cd "$1"

	local i; local p; for i in *; do
		p="$1/$i"
		
		if [[ -L "$p" ]]; then
			continue
		elif [[ -d "$p" ]]; then
			traverse "$p"
		elif [[ -f "$i" ]]; then
			sed "$_regex" "$p" >._replace.sh.tmp
			mv ._replace.sh.tmp "$p"
			echo "$p"
		fi
	done
}

traverse "`pwd`"

