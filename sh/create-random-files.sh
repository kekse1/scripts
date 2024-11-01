#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v1.1.1
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
# JFYI: Since v1.1.0 your 2nd <file size> argument can
# also be negative. In this case the absolute value of
# this defines the maximum file size, which will be
# generated randomly for each file.
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

_max=0

if [[ -z "$COUNT" || -z "$SIZE" || $SIZE -eq 0 ]]; then
	echo "The <file size> may be negative, so each file will have a random size with the maximum (absolute) defined in your <size>" >&2
	echo; echo -e "\tSyntax: \$0 < file amount > < file size > [ < file name length (w/o extension) > [ < extension = $DEFAULT_EXT > ] ]" >&2
	echo; exit 1
elif [[ $SIZE -lt 0 ]]; then
	_max="$((${#SIZE}-1))"
else
	_max="${#SIZE}"
fi

size=0; list=(); size=();
for (( i = 0; i < $COUNT; ++i )); do
	name="`getRandomText ${LEN}`${EXT}"
	while [[ -e "$name" ]]; do
		name="`getRandomText ${LEN}`${EXT}"
	done
	if [[ $SIZE -lt 0 ]]; then
		size=$((($RANDOM%${SIZE:1})+1))
	else
		size=$SIZE
	fi
	$DD if=/dev/urandom of="${name}" bs=1 count=$size >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "Unable to create the file '$name'! So we\'re aborting here, right now." >&2
		if [[ "${#list[@]}" -gt 0 ]]; then
			echo "Files created so far, btw.:"; echo
			for (( i = 0; i < ${#list[@]}; ++i )); do
				printf "    %s \t%${_max}s Bytes\n" "${list[$i]}" "${size[$i]}"
			done; echo
		fi
		exit 3
	else
		list+=( $name )
		size+=( $size )
	fi
done

echo "Successfully created $COUNT files with random data in each of 'em! :-)"
echo
for (( i = 0; i < ${#list[@]}; ++i )); do
	printf "    %s \t%${_max}s Bytes\n" "${list[$i]}" "${size[$i]}"
done
echo

