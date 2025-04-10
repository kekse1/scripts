#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.2
# 
# Syntax: `$0 [ --depth / -d <depth> ] [ --raw / -r ] [ --hidden / -d ] [ --full / -f ]`
# 
# Creates a list of all found extensions. Searching within and below the current working directory (with optional max --depth/-d).
# The '--raw / -r' parameter will prevent any other output (but the list of different extensions itself).
# 

#
real="$(realpath "$0")"
dir="$(dirname "$real")"
base="$(basename "$real")"

#
full=0
hidden=0

#
count=0
raw=0
max=""
short=hdfrd:
long=help,hidden,full,raw,depth:
opts="$(getopt -o "$short" -l "$long" -n "$base" -- "$@")"

if [[ $? -eq 0 ]]; then
	eval set -- "$opts"
else
	exit 1
fi

while true; do
	case "$1" in
		'-d'|'--hidden')
			[[ $hidden -eq 0 ]] && hidden=1 || hidden=0
			shift
			;;
		'-f'|'--full')
			[[ $full -eq 0 ]] && full=1 || full=0
			shift;
			;;
		'-d'|'--depth')
			shift;
			if [[ "$1" =~ ^[0-9]+$ ]]; then
				max="$1"
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
			echo -e "\t[ -h / --help ]          // this info"
			echo -e "\t[ -d / --hidden ]        // also count hidden/dot files"
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

if [[ -z "$max" || $max -le 0 ]]; then
	max=""
else
	echo -e " >> Depth limit set to $max.\n"
	max="-maxdepth $max"
fi

extname1()
{
	local result="$(basename "$*")"
	while [[ "${result::1}" == "." ]]; do
		result="${result:1}"; done
	[[ -z "$result" ]] && return 1
	[[ "$result" =~ "." ]] || return 2
	result="${result#*.}"
	[[ "${result::1}" == "." ]] && return 3
	echo ".${result}"
}

extname2()
{
	local result="$(basename "$*")"
	while [[ "${result::1}" == "." ]]; do
		result="${result:1}"; done
	[[ -z "$result" ]] && return 1
	[[ "$result" =~ "." ]] || return 2
	result="${result##*.}"
	[[ "${result::1}" == "." ]] && return 3
	echo ".${result}"
}

extname()
{
	if [[ $full -eq 0 ]]; then
		extname2 "$*"
		return $?
	fi

	extname1 "$*"
	return $?
}

#
FIND="find $max -not -name .."
[[ $hidden -eq 1 ]] && FIND+=" -not -name '.*'"
FIND+=" -print0"

declare -A COUNT

while IFS= read -r -d '' file; do
	ext="$(extname "$file")"
	[[ $? -ne 0 ]] && continue
	[[ -v COUNT["$ext"] ]] || let count=$count+1
	COUNT["$ext"]=$((COUNT["$ext"]+1))
done < <(eval "$FIND")

#
if [[ $raw -ne 0 ]]; then
	for i in "${!COUNT[@]}"; do
		echo "$i"
	done; exit
else
	echo -e " >> Found $count different extensions.\n"
fi

_max=0

for i in "${!COUNT[@]}"; do
	[[ ${#i} -gt $_max ]] && _max=${#i}
done

for i in "${!COUNT[@]}"; do
	printf "%${_max}s %d\n" "$i" "${COUNT[$i]}"
done

echo

