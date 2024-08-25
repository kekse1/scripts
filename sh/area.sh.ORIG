#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.1
#
# You should put this script into your '/etc/profile.d/'
# directory, so the `area` function will get `source`d.
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
# of the input line count. They won't be modulo'd (%), so
# they shouldn't exceed the limit.
#
# The parameters are selected merely intelligent: they'll
# be tested. You can define the file path in the first,
# second or third parameter. The (optional) first integer
# will be the <from>, the (also optional) second one will
# be the <to>. If <from> is greater than <to>, they'll swap,
# so it doesn't matter in which order you define 'em.
#
# If no line number(s) is/are defined, the real line *count*
# is printed. Otherwise the single line or the area between
# <from> and <to>. And if no file path is defined, it'll use
# the stdin (which can also be defined via "-" as parameter).
#
# JFYI: The first plan was to just use `head` and `tail`, but
# it'd be expensive with big data (it would read the data twice,
# since twice calls are necessary). So I read out the data on my
# own here. In the first second this was also expensive, since
# the whole data would be read into memory. Now I fixed this
# by counting lines, but only store the really necessary/wished
# lines. The last (TODO) point: before reading the data on my
# own, I'm using the `wc` utility.. so the data is being read
# twice, again.. at least it's not stored in memory then, this
# is good, but I'm not counting the lines on my own since the
# defined line numbers can only be calculated after knowing the
# line count (e.g. negative values are counted from the end)...
#

area()
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

	lines=$(wc -l "$file" | cut -d' ' -f1)

	if [[ -z "$from" ]]; then
		echo "$lines"
		return 0
	fi
	
	[[ $from -lt 0 ]] && from=$((${lines}+${from}+1))

	if [[ $from -lt 1 ]]; then
		echo " >> Starting line number needs to be greater than zero." >&2
		return 7
	elif [[ $from -gt $lines ]]; then
		echo " >> Starting line number exceeds input line count ($lines)." >&2
		return 8
	fi
	
	if [[ -n "$to" ]]; then
		[[ $to -lt 0 ]] && to=$((${lines}+${to}+1))

		if [[ $from -gt $to ]]; then
			(( from = from + to ))
			(( to = from - to ))
			(( from = from - to ))
		fi

		if [[ $to -lt $from ]]; then
			echo " >> Ending line number may not be lower than starting line." >&2
			return 8
		elif [[ $to -gt $lines ]]; then
			echo " >> Ending line number exceeds input line count ($lines)." >&2
			return 10
		fi
	else
		to=$from
	fi

	current=0
	
	while read line; do
		let current=$current+1
		[[ $current -ge $from && $current -le $to ]] && echo "$line"
	done <"$file"
}
