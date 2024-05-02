#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.0
#
# The main reason for this script was: my Node.js projects need to handle
# whole block devices oder partitions. But I wanted to configure them by
# their (PART)UUID, so there'd be no problems when regular '/dev/sdb' or
# so change (which can happen, and this is a big problem!).
#
# In Node.js there's no regular way to open devices/partitions by their
# (PART)UUID; additionally, I couldn't get the sizes of the partitions
# or drives via `fstat*()`..
#
# Since I already use a shell script to start my project (with WatchDog,
# Singleton-Styles by '.pid'-file, and more reasons for this..), I just
# needed to utilize Linux capabilities.. and I chosed `lsblk` for this,
# since it doesn't need superuser privileges (`blkid` or `fdisk` need it).
#
# The second reason was: using bash arrays and a special syntax to split
# the `--pairs` output into key/value etc., I wanted to leave myself a
# hint for future shell scripts.. and for you! Note, that I marked out
# for you where to use `case`, if you'd like to manage the key/value pairs.
#
# So just argue with your UUID (e.g.. or change the --output's), and this
# script will get you some key-value pairs with more infos (again, see the
# --output parameter of `lsblk`..).
#
# But you can also use an empty search parameter when using only quotes \'\';
# and you can define more output parameters via additional command line
# parameters, see the `lsblk --help` output for these ones. So you can
# also search for (and see) more than just the UUIDs, paths or sizes. :-)
#
# Have phun! The cake.
#

_lsblk="$(which lsblk 2>/dev/null)"

if [[ -z "$_lsblk" ]]; then
	echo " >> The \`lsblk\` utility couldn't be found!" >&2
	exit 1
elif [[ $# -eq 0 ]]; then
	echo " >> Syntax: \$0 <grep> [ <output parameter> [ ... ] ]" >&2
	exit 2
fi

#
GREP="$1"
shift
OUTPUT="NAME,PATH,SIZE,UUID,PARTUUID"

if [[ -n "$1" ]]; then
	for i in "$@"; do
		OUTPUT="${OUTPUT},${i^^}"
	done
fi

IFS=',' output=( $OUTPUT )
maxLen=0

for i in "${output[@]}"; do
	len=${#i}
	[[ $maxLen -lt $len ]] && maxLen=$len
done

let maxLen=$maxLen+1
IFS=''

#
echo " >> Grepping for '$GREP' (not case sensitive)"
echo " >> Output parameters: ${OUTPUT}"
echo

#
OUTPUT="$($_lsblk --bytes --output $OUTPUT --pairs | grep -i "$GREP")"
COUNT=0
IFS=$'\n'
for line in $OUTPUT; do
	let COUNT=$COUNT+1
	IFS=' ' vector=( $line )
	for pair in "${vector[@]}"; do
		key="${pair%%=*}"
		value="${pair#*=}"
		value="${value#\"}"
		value="${value%\"}"

		#echo "[$key] $value"
		printf "%${maxLen}s: %s\n" "$key" "$value"

		#
		#here you could use 'case' etc..!
		#
	done
	echo
done

echo " >> Found ${COUNT} items."

