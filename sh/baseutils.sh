#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.3.0
#

#
mkcd()
{
	if [ $# -eq 0 ]; then
		echo "Syntax: mkcd <directory>" >&2
		return 1
	fi
	mkdir -pv "$*" || return $?
	cd "$*"
	pwd
}

# like `Date.now()`: milliseconds
now()
{
	echo "$((`date +%s%N`/1000000))"
}

# nanoseconds (you could also perfectly `alias` this)
nano()
{
	echo "`date +%s%N`"
}

from()
{
	if [[ $# -lt 2 ]]; then
		echo "Syntax: below <from line> <input file>" >&2
		return 1
	elif [[ ! "$1" =~ ^[0-9]+$ ]]; then
		echo "First parameter needs to be a positive integer." >&2
		return 2
	elif [[ $1 -lt 0 ]]; then # TODO: evtl. koennen negative auch sinnvoll sein?!!?
		echo "First parameter may not be below zero." >&2
		return 3
	elif [[ -z "$2" ]]; then
		echo "The input file parameter may not be empty." >&2
		return 4
	fi

	from=$1
	shift
	file="$*"

	if [[ ! -r "$file" ]]; then
		echo "Your input file is not readable (or doesn't even exist)." >&2
		return 5
	fi

	cat "$file" | tail -n$((`cat "$file" | wc -l`-$from+1))
}

#
extname()
{
	# my own version w/ $count argument, see lib/v4/..!
	echo TODO >&2
	return 255
}

relative()
{
	# relative path $from $to
	echo TODO >&2
	return 255
}

absolute()
{
	[[ "${1::1}" == "/" ]] && return 0
	return 1
}

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

eol()
{
	echo TODO >&2
	return 255
	#using $count
}

pad()
{
	echo TODO >&2
	return 255
	# am einfachsten `printf` nutzen, hm?
	# sonst selbst machen.. ^_^
}

repeat()
{
	echo TODO >&2
	return 255
	# `repeat $count $*`
	# vs. stdin '-'!??
}

yesno()
{
	echo TODO >&2
	return 255
	# ask as long as no real "y[es]/n[o]"!
}

lower()
{
	echo "${*,,}"
}

upper()
{
	echo "${*^^}"
}

#
