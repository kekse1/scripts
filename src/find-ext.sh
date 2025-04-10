#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.0
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
FULL=0

#
count=0
raw=0
max=""
short=hfrd:
long=help,full,raw,depth:
opts="$(getopt -o "$short" -l "$long" -n "$base" -- "$@")"

if [[ $? -eq 0 ]]; then
	eval set -- "$opts"
else
	exit 1
fi

while true; do
	case "$1" in
		'-f'|'--full')
			[[ $FULL -eq 0 ]] && FULL=1 || FULL=0
			shift;
			;;
		'-d'|'--depth')
			shift;
			if [[ "$1" =~ ^[0-9]+$ ]]; then
				max="-maxdepth $1"
				shift 2
			else
				echo " >> Parameter for --depth / -d needs to be a positive integer!" >&2
				exit 2
			fi
			shift;
			;;
		'-r'|'--raw')
			[[ $raw -eq 0 ]] && raw=1 || raw=0
			shift
			;;
		'-h'|'--help')
			echo -e "\nSyntax: $(basename "$0")\n"
			echo -e "\t[ -d / --depth <depth> ] // directory depth"
			echo -e "\t[ -r / --raw ]           // no other output than the result(s)"
			echo -e "\t[ -f / --full ]          // full extensions instead of only the last one"
			echo; exit
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

extname1()
{
	[[ "$*" =~ "." ]] || return 1
	local result="$(basename "$*")"
	result=".${result#*}"
	echo "$result"
}

extname2()
{
	[[ "$*" =~ "." ]] || return 1
	local result="$(basename "$*")"
	result=".${result##*.}"
	echo "$result"
}

extname()
{
	if [[ $FULL -eq 0 ]]; then
		extname2 "$*"
		return $?
	fi

	extname1 "$*"
	return $?
}

#
declare -A COUNT

while IFS= read -r -d '' file; do
	ext="$(extname "$file")"
	[[ $? -ne 0 ]] && continue
	if [[ ! -v COUNT["$ext"] ]]; then
		let count=$count+1
	fi
	COUNT["$ext"]=$((COUNT["$ext"]+1))
done < <(find $max -not -name . -not -name .. -print0)

#
if [[ $raw -ne 0 ]]; then
	for i in "${!COUNT[@]}"; do
		echo "$i"
	done; exit
else
	echo -e "\n >> Found $count different extensions.\n"
fi

_max=0

for i in "${!COUNT[@]}"; do
	[[ ${#i} -gt $_max ]] && _max=${#i}
done

for i in "${!COUNT[@]}"; do
	printf "[%${_max}s] %d\n" "$i" "${COUNT[$i]}"
done

