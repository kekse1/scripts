#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.0
# 
# Finds file duplicates. You define a target directory
# and an optional depth (defaults to 1, so only the
# current directory), and in your target directory
# there'll be files with names out of the `sha224sum`,
# and the original extensions.
#

#
syntax()
{
	echo "Syntax: `basename "$0"` <target directory> [ <depth> ]" >&2
	exit $1
}

#
target="$1"
depth="$2"

if [[ -z "$target" ]]; then
	echo "Missing target directory!" >&2
	syntax 1
elif [[ -d "$target" ]]; then
	target="$(realpath "$target")"
	echo "Real target directory: '$target'"
else
	mkdir -p "$target"

	if [[ $? -ne 0 ]]; then
		echo "Unable to create target directory!" >&2
		exit 2
	fi
fi

[[ -z "$depth" ]] && depth=1

#
sha224()
{
	echo "`sha224sum "$1" | cut -d' ' -f1`"
}

extname()
{
	result="`basename "$1"`"
	result=".${result#*.}"
	echo "$result"
}

confirm()
{
	[[ -n "$1" ]] && echo -ne "$1 [Yes/No]? "
	read confirm; confirm="${confirm::1}"; confirm="${confirm,,}"
	[[ "$confirm" != "y" ]] && return 1
	return 0
}

#
files=()

while IFS= read -r -d '' file; do
	files+=( "$file" )
done < <(find ./ -maxdepth "$depth" -type f -print0)

echo "Found ${#files[@]} files (with a maximum depth of ${depth}):"
echo

for (( i=0; i < ${#files[@]}; ++i )); do
	file="${files[$i]}"
	ext="`extname "$file"`"
	hash="`sha224 "$file"`"
	echo "[${file}] ${hash}"
	cp "$file" "${target}/${hash}${ext}" 2>/dev/null
done

echo
echo "Now look into '${target}'"

