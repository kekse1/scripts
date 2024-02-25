#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.2
# 
# Syntax: `$0 [ --depth / -d <depth> ] [ --raw / -r ]`
# 
# Creates a list of all found extensions. Searching within and below the current working directory (with optional max --depth/-d).
# The '--raw / -r' parameter will prevent any other output (but the list of different extensions itself).
# 

#
real="$(realpath "$0")"
dir="$(dirname "$real")"
base="$(basename "$real")"

#
result=""
count=0
raw=0
max=""
short=hrd:
long=help,raw,depth:
opts="$(getopt -o "$short" -l "$long" -n "$base" -- "$@")"

if [[ $? -eq 0 ]]; then
	eval set -- "$opts"
else
	exit 1
fi

while true; do
	case "$1" in
		'-d'|'--depth')
			if [[ "$2" =~ ^[0-9]+$ ]]; then
				max="-maxdepth $2"
				shift 2
			else
				echo " >> Parameter for --depth / -d needs to be *numeric/integer*!" >&2
				exit 2
			fi
			;;
		'-r'|'--raw')
			raw=1
			shift
			;;
		'-h'|'--help')
			echo "Syntax: $base [ --depth / -d <depth> ] [ --raw / -r ]"
			exit
			;;
		'--')
			shift
			break
			;;
	esac
done

if [[ ! -z "$max" && $raw -eq 0 ]]; then
	echo -e " >> Depth limit is set to $max.\n" >&2
fi

getExtension()
{
	res="${*##*/}"
	res="${res:1}"

	if [[ $res = *'.'* ]]; then
		echo ".${res##*.}"
	fi
}

inArray()
{
	for i in $result; do
		[[ "$i" = "$*" ]] && return 0
	done
	return 1
}

while IFS= read -r -d '' file; do
	ext="`getExtension "$file"`"
	[[ -z "$ext" ]] && continue
	inArray "$ext"
	if [[ $? -ne 0 ]]; then
	       result="$result $ext"
	       let count=$count+1
	fi
done < <(find $max -not -name . -not -name .. -print0)

result="${result:1}"
for i in $result; do
	echo $i
done

[[ $raw -eq 0 ]] && echo -e "\n >> Found $count different extensions." >&2
