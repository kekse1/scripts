#!/usr/bin/env bash
#
# Tiny helper.. Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# 
# Without at least two parameters a tiny syntax helping error will be shown.
# If third parameter is not defined, we search in the current directory.
# 
# Warning: changing all files means that also scripts which need +x will change!
# So you can define one or many file extensions to '$ignore'!
#

ignore=".js .sh .php"
ignore_git="yes"

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
ign=0

IFS=$'\n'

for i in `find "$path" -type d`; do
	next=0

	if [[ $next -eq 0 && -n $ignore ]]; then
		IFS=' '
		for j in $ignore; do
			[[ -z $j ]] && continue
			if [[ "$j" = "${i: -${#j}}" ]]; then
				next=1
				break
			fi
		done
		IFS=$'\n'
	fi

	if [[ $next -ne 0 ]]; then
		let ign=$ign+1
	else
		chmod $dir "$i"
		[[ $? -ne 0 ]] && let err=$err+1
	fi

	let dirs=$dirs+1
done

for i in `find "$path" -type f`; do
	next=0

	if [[ -n $ignore ]]; then
		IFS=' '
		for j in $ignore; do
			[[ -z $j ]] && continue
			if [[ "$j" = "${i: -${#j}}" ]]; then
				next=1
				break
			fi
		done
		IFS=$'\n'
	fi

	if [[ $next -ne 0 ]]; then
		let ign=$ign+1
	else
		chmod $file "$i"
		[[ $? -ne 0 ]] && let err=$err+1
	fi

	let files=$files+1
done

total="$(($dirs+$files))"
echo " >> Changed mode of $dirs directories and $files files (so $total in total)."
[[ $err -gt 0 ]] && echo " >> With $err errors.. :-/" >&2
[[ $ign -gt 0 ]] && echo " >> Ignored $ign items.."

