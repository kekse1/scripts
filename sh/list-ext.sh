#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/
# v0.0.2
#
# Creates a list of all found extensions. Searching below the current working directory.
# If called with numerical parameter, this is limiting the maximum recursion depth (`find -maxdepth`).
#
# Syntax: `$0 [ <maxdepth> ]`
#

result=""
count=0
max="$1"

if [[ $max =~ ^[0-9]+$ ]]; then
	echo -e " >> Depth limit is set to $max.\n" >&2
	max="-maxdepth $max"
else
	max=""
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

echo -e "\n >> Found $count different extensions." >&2

