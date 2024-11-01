#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v1.0.0
#
# My `norbert` needed some random input data, from a
# directory I wanted to propagate with some temporary
# files (of an exactly defined file size).
#
# So I created this tiny tool. Requirements: the `dd`.
#
# Have phun!
#
# PS: You can also take the function `getRandomText()` below
# and put it into some of your '/etc/profile.d/*'. ;-)
#

#
DEFAULT_EXT=".tmp"
DEFAULT_LEN=8

# 
# $0 <length>
#
chars="abcdefghijklmnopqrstuvwxyz"
getRandomText()
{
	length=$1; result=""
	for i in `seq 1 $length`; do
		result="${result}${chars:$(($RANDOM%${#chars})):1}"
	done; echo $result
}

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
LEN="$3"
EXT="$4"

[[ -z "$LEN" ]] && LEN=$DEFAULT_LEN
[[ -z "$EXT" ]] && EXT=$DEFAULT_EXT
[[ "${EXT::1}" != "." ]] && EXT=".${EXT}"

if [[ -z "$COUNT" || -z "$SIZE" ]]; then
	echo "Syntax: \$0 < file amount > < file size > [ < file name length (w/o extension) > [ < extension = $DEFAULT_EXT > ] ]" >&2
	exit 1
fi

list=()
for (( i = 0; i < $COUNT; ++i )); do
	name="`getRandomText ${LEN}`${EXT}"
	while [[ -e "$name" ]]; do
		name="`getRandomText ${LEN}`${EXT}"
	done
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

