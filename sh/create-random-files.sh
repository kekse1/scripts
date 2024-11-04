#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v1.5.0
#
# My `norbert` needed some random input data, from a
# directory I wanted to propagate with some temporary
# files (of an exactly defined file size).
#
# So I created this tiny tool. Requirements: the `dd`.
#
# Have phun!
#
# JFYI: Since v1.1.0 the 1st, 2nd and 3rd argument can
# also be negative. In this case the absolute value of
# them defines the maximum of randomly generated params.
#
# PS: You can also take the functions `randomChars()`
# with `random()` and put it into your '/etc/profile.d/*'.
#

#
CHARS="abcdefghijklmnopqrstuvwxyz"
DEFAULT_EXT=".tmp"
DEFAULT_LENGTH=8

#
if [[ -z "$RANDOM" ]]; then
	echo "There's no \$RANDOM available!" >&2
	exit 234
fi

# 
# $0 <length>
#

randomChars()
{
	length=$1; result=""
	for i in `seq 1 $length`; do
		result="${result}${CHARS:$(($RANDOM%${#CHARS})):1}"
	done; echo $result
}

random()
{
	max=$1
	min=$2

	[[ -z "$max" ]] && max=255
	[[ -z "$min" ]] && min=0

	echo "$(((${RANDOM}%(${max}-${min}+1))+${min}))"
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

[[ -z "$LEN" ]] && LEN=$DEFAULT_LENGTH
[[ -z "$EXT" ]] && EXT=$DEFAULT_EXT
[[ "${EXT::1}" != "." ]] && EXT=".${EXT}"

if [[ -z "$COUNT" || -z "$SIZE" || $SIZE -eq 0 || $LEN -eq 0 || $COUNT -eq 0 ]]; then
	echo "The <file size> and <file name length> can be negative, which would be the maximum of random values for them." >&2
	echo; echo -e "\tSyntax: \$0 < file amount > < file size > [ < file name length = $DEFAULT_LENGTH > [ < extension = $DEFAULT_EXT > ] ]" >&2
	echo; exit 1
fi

_random_size=0
_random_len=0

if [[ $SIZE -lt 0 ]]; then
	SIZE="${SIZE:1}"
	_random_size=1
fi

if [[ $LEN -lt 0 ]]; then
	LEN="${LEN:1}"
	_random_len=1
fi

if [[ $COUNT -lt 0 ]]; then
	COUNT="${COUNT:1}"
	COUNT=`random $COUNT 1`
fi

#
_max_name=0; _max_size=0; size=$SIZE; len=$LEN; list=(); sizes=();
for (( i = 0; i < $COUNT; ++i )); do
	[[ $_random_size -ne 0 ]] && size=`random $SIZE`
	[[ $_random_len -ne 0 ]] && len=`random $LEN 1`
	name="`randomChars ${len}`${EXT}"
	[[ ${#name} -gt $_max_name ]] && _max_name=${#name}
	tmp=$((${#size}+6)); [[ $tmp -gt $_max_size ]] && _max_size=$tmp
	$DD if=/dev/urandom of="${name}" bs=1 count=$size >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "Unable to create the file '$name'! So we\'re aborting here, right now." >&2
		if [[ "${#list[@]}" -gt 0 ]]; then
			echo "Files created so far, btw.:"; echo
			for (( i = 0; i < ${#list[@]}; ++i )); do
				if [[ $_random_size -eq 0 ]]; then
					echo "${list[$i]}"
				else
					printf "%-${_max_name}s\t\e[1m%${_max_size}s\e[0m Bytes\n" "${list[$i]}" "${size[$i]}"
				fi
			done; echo
		fi
		exit 4
	else
		list+=( $name )
		sizes+=( $size )
	fi
done

for (( i = 0; i < ${#list[@]}; ++i )); do
	if [[ $_random_size -eq 0 ]]; then
		echo "${list[$i]}"
	else
		printf "%-${_max_name}s\t\e[1m%${_max_size}s\e[0m Bytes\n" "${list[$i]}" "${sizes[$i]}"
	fi
done
