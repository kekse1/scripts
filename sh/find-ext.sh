#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/
# v0.0.3
#
# Creates a list of all found extensions. Searching below the current working directory.
# If called with numerical parameter, this is limiting the maximum recursion depth (`find -maxdepth`).
#
# Syntax: `$0 [ <maxdepth> ] [ -raw / -r ]`
#
# The '-raw / -r' parameter will prevent any other output (but the list of different extensions itself).
#

result=""
count=0
raw=0
max=""

for i in "$@"; do
	if [[ "$i" = "--raw" || "$i" = "-r" ]]; then
		raw=1
	elif [[ "$i" =~ ^[0-9]+$ ]]; then
		max="-maxdepth $i"
	fi
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
