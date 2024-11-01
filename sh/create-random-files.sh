#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.3.0
#
# My `norbert` needed some random input data, from a
# directory I wanted to propagate with some temporary
# files (of an exactly defined file size).
#
# So I created this tiny tool. Requirements: the `dd` utility,
# and the `openssl` tool. .. have phun!
#

#
DEFAULT_EXT=".tmp"
DEFAULT_NAME=8

#
[[ "${DEFAULT_EXT::1}" != "." ]] && DEFAULT_EXT=".${DEFAULT_EXT}"

#
OPENSSL="openssl"
OPENSSL="`which $OPENSSL 2>/dev/null`"

if [[ $? -ne 0 ]]; then
	echo "Missing the \`openssl\` tool!" >&2
	exit 2
fi

DD="dd"
DD="`which $DD 2>/dev/null`"

if [[ $? -ne 0 ]]; then
	echo "Missing the \`dd\` utility!" >&2
	exit 3
fi

#
COUNT="$1"
SIZE="$2"
NAME="$3"
EXT="$4"

[[ -z "$NAME" ]] && NAME=$DEFAULT_NAME
[[ -z "$EXT" ]] && EXT=$DEFAULT_EXT
[[ "${EXT::1}" != "." ]] && EXT=".${EXT}"

if [[ -z "$COUNT" || -z "$SIZE" ]]; then
	echo "Syntax: \$0 < file amount > < file size > [ < file name length (w/o extension) > [ < extension = $DEFAULT_EXT > ] ]" >&2
	exit 1
fi

list=()
for (( i = 0; i < $COUNT; ++i )); do
	name="$(openssl rand -hex $NAME)${EXT}"
	$DD if=/dev/urandom of="${name}" bs=1 count=$SIZE >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "Unable to create the file '$name'! So we\'re aborting here, right now." >&2
		if [[ "${#list[@]}" -gt 0 ]]; then
			echo "Files created so far, btw.:"; echo
			for i in "${list[@]}"; do
				echo "    $i"
			done; echo
		fi
		exit 3
	else
		list+=( $name )
	fi
done

echo "Successfully created $COUNT files with $SIZE Bytes of random data in each of 'em! :-)"
echo
for i in "${list[@]}"; do
	echo "    $i"
done
echo

