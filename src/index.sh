#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.3
# 
# Finds file duplicates, or just creates an index with
# the file hashes..
#
# You define a target directory and an optional depth
# (defaults to 1, so only the current directory), and
# in your target directory there'll be files with names
# out of their `sha224sum`, with original extensions.
#
# BTW: see also my new `inc.sh`!
# Both together are better. :-)
#

# 
# TODO # please tell the user which original files were duplicates, too..
# 

#
# change this setting for either `extname1` or `extname2` (see below); ..
#
FULL=0

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
else
	target="$(realpath "$target")/"
	[[ $? -ne 0 ]] && exit 2
	echo -n "Using target directory: '$target' "
	if [[ -d "$target" ]]; then
		echo "(already exists)"
	else
		echo "(will be created)"
	fi
fi

[[ -z "$depth" ]] && depth=1

#
sha224()
{
	echo "`sha224sum "$1" | cut -d' ' -f1`"
}

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
	if [[ $FULL -eq 0 ]]; then
		extname2 "$*"
		return $?
	fi

	extname1 "$*"
	return $?
}

confirm()
{
	[[ -n "$1" ]] && echo -ne "$1 [Yes/No]? "
	local confirm; read confirm; confirm="${confirm::1}"; confirm="${confirm,,}"
	[[ "$confirm" != "y" ]] && return 1
	return 0
}

#
files=()

while IFS= read -r -d '' file; do
	files+=( "$file" )
done < <(find ./ -maxdepth "$depth" -type f -print0)

echo "Found ${#files[@]} files (with a maximum depth of ${depth})."
confirm "Do you want to continue"
if [[ $? -ne 0 ]]; then
	echo "Aborted by user request." >&2
	exit 3
else
	echo
fi

mkdir -pv "$target" 2>/dev/null

for (( i=0; i < ${#files[@]}; ++i )); do
	file="${files[$i]}"
	ext="`extname "$file"`"
	[[ $? -ne 0 ]] && continue
	hash="`sha224 "$file"`"
	echo "[${file}] ${hash}"
	cp "$file" "${target}/${hash}${ext}" 2>/dev/null
done

echo
echo "Now look into '${target}'."

