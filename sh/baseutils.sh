#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://baseutils.org/
# v0.2.2
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

eol()
{
	echo TODO >&2
	return 255
	#using $count
}

line()
{
	echo TODO >&2
	return 255
	#with $str, using width() (below)
}

width()
{
	if [[ -n "$COLUMNS" ]]; then
		echo $COLUMNS
	else
		tput cols
	fi
}

height()
{
	if [[ -n "$LINES" ]]; then
		echo $LINES
	else
		tput lines
	fi
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
