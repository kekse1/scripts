#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/
# v0.0.1
#
# Copies all files with defined extension(s) to one target directory for all
# (recursively searched source files, btw).
#
# Syntax: $0 < target directory > < ext > [ < ext > ... ] >
#

target="$1"
shift
extensions=("$@")

if [[ -z "$target" ]]; then
	echo -e " >> Missing target directory!" >&2
	exit 1
else
	if [[ ${#extensions[@]} -eq 0 ]]; then
		echo -e " >> Missing extension(s)!" >&2
		exit 2
	else
		echo -e " >> Moving all files with following extensions to '$target':"
	fi

	for (( i = 0; i < ${#extensions[@]}; ++i )); do
		if [[ "${extensions[$i]:0:1}" != "." ]]; then
			extensions[$i]=".${extensions[$i]}"
		fi
		
		echo "'${extensions[$i]}'"
	done
fi

for ext in "${extensions[@]}"; do
	while IFS= read -r -d '' file; do
		echo "Found: '$file'"
		mv "$file" "$target"
	done < <(find . -type f -iname "*$ext" -print0)
done

