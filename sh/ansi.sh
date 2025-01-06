#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.0
#
# Starting with a shell script (to be `source`d) for
# ANSI escape sequences.
#
# You either need to manually `source` or `.` in your shell
# (it's NOT executable), or copy it to `/etc/profile.d/ansi.sh`.
#

#
export LINE='='

#
line()
{
	w=`width`; if [[ $w -eq 0 ]]; then echo; return; fi
	IFS=$'\n'; line="$*"; [[ -z "$line" ]] && line="$LINE"; [[ -z "$line" ]] && line="="
	for (( i=0; i<$w; ++i )); do
		mod=$((${i}%${#line}));
		echo -n "${line:${mod}:1}"
	done; echo
}

width()
{
	if [[ -n "$COLS" ]]; then
		echo $COLS
	elif [[ -n "$COLUMNS" ]]; then
		echo $COLUMNS
	else
		tput cols 2>/dev/null

		if [[ $? -ne 0 ]]; then
		       echo 0
		       return 1
		fi
	fi
}

height()
{
	if [[ -n "$LINES" ]]; then
		echo $LINES
	else
		tput lines 2>/dev/null

		if [[ $? -ne 0 ]]; then
		       echo 0
		       return 1
		fi
	fi
}

#
none()
{
	echo -en '\e[0m'
}

#
fg()
{
	echo -en "\e[38;2;$1;$2;$3m"

	if [[ -n "$4" ]]; then
	       echo -en "$4\e[39m"
	fi
}

bg()
{
	echo -en "\e[48;2;$1;$2;$3m"

	if [[ -n "$4" ]]; then
		echo -en "$4\e[49m"
	fi
}

info()
{
	fg 173 234 68 "$*"
}

warn()
{
	fg 232 226 37 "$*"
}

error()
{
	fg 252 131 38 "$*"
}

debug()
{
	fg 150 180 200 "$*"
}

bold()
{
	echo -en "\e[1m"

	if [[ -n "$*" ]]; then
		echo -en "$*\e[0m"
	fi
}

underline()
{
	echo -en "\e[4m"

	if [[ -n "$*" ]]; then
		echo -en "$*\e[24m"
	fi
}

italic()
{
	echo -en "\e[3m"

	if [[ -n "$*" ]]; then
		echo -en "$*\e[23m"
	fi
}

faint()
{
	echo -en "\e[2m"

	if [[ -n "$*" ]]; then
		echo -en "$*\e[22m"
	fi
}

