#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.4.0
#
# You should put this script into your '/etc/profile.d/'
# directory, so the `lines()` function will get `source`d.
#
# Simple script you can use with either a file path parameter
# or the stdin '-' (if defined at all), to perform one of
# these actions:
#
# 	(a) display the line count of your input
# 	(b) extract a specific line
# 	(c) extract an area of lines
# 
# Line numbers can be negative: they'll count from the end
# of the input line count.
#
# If no line number(s) is/are defined, the real line *count*
# is printed. Otherwise the single line or the area between
# <from> and <to>. And if no file path is defined, it'll use
# the stdin (which can also be defined via "-" as parameter).
#
# The parameters are selected merely intelligent: they'll
# be tested. You can define the file path in the first,
# second or third parameter. The (optional) first integer
# will be the <from>, the (also optional) second one will
# be the <to>. If <from> is greater than <to>, they'll swap,
# so it doesn't matter in which order you define 'em.
#
# JFYI: The first version used `head` and `tail`, but  it's
# to expensive with big data (it would read the data twice,
# since twice calls are necessary). So I read out the data
# on my own here.
#

lines()
{
	isInt()
	{
		if [[ "$*" =~ ^[-]?[0-9]+$ ]]; then
			echo 0
			return 0
		fi

		echo 1
		return 1
	}

	withFile=''
	file=''
	from=''
	to=''

	if [[ -z "$1" ]]; then
		echo " >> No parameter may be be empty (but your first one is..)." >&2
		return 1
	elif [[ `isInt $1` -eq 0 ]]; then
		from=$1
	else
		file="$1"
		withFile=1
	fi

	if [[ $# -gt 1 ]]; then
		if [[ -z "$2" ]]; then
			echo " >> No parameter may be empty (but your second one is..)." >&2
			return 2
		elif [[ `isInt $2` -eq 0 ]]; then
			if [[ -z "$from" ]]; then
				from=$2
			else
				to=$2
			fi
		elif [[ "$2" != "-" ]]; then
			if [[ $withFile -eq 0 ]]; then
				file="$2"
				withFile=1
			else
				echo " >> You can't define more than one input file." >&2
				return 3
			fi
		else
			file="-"
			withFile=0
		fi
	elif [[ -z "$withFile" ]]; then
		withFile=0
		file="-"
	fi

	if [[ $# -gt 2 ]]; then
		if [[ -z "$2" ]]; then
			echo " >> No parameter may be empty (but your third one is..)." >&2
			return 4
		elif [[ `isInt $3` -eq 0 ]]; then
			if [[ -z "$from" ]]; then
				from=$3
			elif [[ -z "$to" ]]; then
				to=$3
			fi
		elif [[ -z "$withFile" ]]; then
			file="$3"
			withFile=1
		else
			withFile=0
		fi
	elif [[ -z "$withFile" ]]; then
		withFile=0
		file="-"
	fi


	if [[ -z "$withFile" ]]; then
		withFile=0
		file="-"
	fi

	if [[ "$file" == "-" ]]; then
		file="/dev/stdin"
		withFile=0
	elif [[ ! -e "$file" ]]; then
		echo " >> Your file doesn't exist!" >&2
		return 4
	elif [[ ! -f "$file" ]]; then
		echo " >> Your path doesn't point to a regular file!" >&2
		return 5
	elif [[ ! -r "$file" ]]; then
		echo " >> Your file isn't readable!" >&2
		return 6
	fi

	if [[ -z $from || $from -eq 0 ]]; then
		echo "$(cat "$file" | wc -l)"
		return
	elif [[ -z $to ]]; then
		to=$from
	fi

	lines=$(cat "$file" | wc -l)

	from=$((${from}%${lines}))
	to=$((${to}%${lines}))

//TODO/

echo -e "[from] $from\n  [to] $to\n"
return 123
	
	if [[ $from -gt $to ]]; then
		(( from = from + to ))
		(( to = from - to ))
		(( from = from - to ))
	fi

	current=0; IFS=$'\n'; while read line; do
		let current=$current+1
		if [[ $current -ge $from && $current -le $to ]]; then
		       echo -e "$line"
	       elif [[ $current -gt $to ]]; then
		       break
		fi
	done <"$file"
}

