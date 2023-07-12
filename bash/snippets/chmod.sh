#!/usr/bin/env bash
#
# Tiny helper.. Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# 
# Without at least two parameters a tiny syntax helping error will be shown.
# If third parameter is not defined, we search in the current directory.
# 
# Warning: changing all files means that also scripts which need +x will change!
# (TODO!)
#

if [[ -z $1 || -z $2 ]]; then
	echo " >> Syntax: `basename $0` < dir mode > < file mode > [ directory ]" >&2
	exit 1
fi

path=""

if [[ -n $3 ]]; then
	path="`realpath $3`"

	if [[ ! -d "$path" ]]; then
		echo " >> Invalid directory '$path'!" >&2
		exit 2
	fi
else
	path="`realpath .`"
fi

dir=$1
file=$2
dirs=0
files=0
err=0

IFS=$'\n'

for i in `find "$path" -type d`; do
	chmod $dir "$i"
	[[ $? -ne 0 ]] && let err=$err+1
	let dirs=$dirs+1
done

for i in `find "$path" -type f`; do
	chmod $file "$i"
	[[ $? -ne 0 ]] && let err=$err+1
	let files=$files+1
done

echo " >> Changed mode of $dirs directories and $files files."
[[ $err -gt 0 ]] && echo " >> With $err errors.. :-/" >&2

