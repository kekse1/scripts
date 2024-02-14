#!/usr/bin/env bash
#
# Tiny helper.. Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# 
# Without at least two parameters a tiny syntax helping error will be shown.
# If third parameter is not defined, we search in the current directory.
# 
# Warning: changing all files means that also scripts which need +x will change!
# So you can define one or many file extensions to '$ignore'!
# Additionally, set "hidden=yes" to also match hidden dot-files ('.' prefixed ones).
#

ignore=".git"
hidden="yes"

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

if [[ "$hidden" = "yes" ]]; then
	shopt -s dotglob
fi

dir=$1
file=$2
dirs=0
files=0
err=0
errFiles=""
ign=0

recursive_chmod()
{
	local res=-1
	local path="$1"
	local next=0

	[[ -z "$path" ]] && return
	[[ ! -e "$path" ]] && return

	[[ -n "$ignore" ]] && for j in $ignore; do
		if [[ -z "$j" ]]; then
			continue
		elif [[ "`basename "$path"`" = "$j" ]]; then
			next=1
			break;
		elif [[ "$j" = "${i: -${#j}}" ]]; then
			next=1
			break
		fi
	done

	[[ $next -ne 0 ]] && return
	local res=-1

	if [[ -d "$path" ]]; then
		let dirs=$dirs+1
		chmod $dir "$path"
		res=$?
	else
		let files=$files+1
		chmod $file "$path"
		res=$?
	fi

	if [[ $res -gt 0 ]]; then
		let err=$err+1
		errFiles="$errFiles
$path"
	fi

	[[ -d "$path" ]] && for i in "$path"/*; do
		recursive_chmod "$i"
	done
}

recursive_chmod "$path"

total="$(($dirs+$files))"
echo " >> Changed mode of $dirs directories and $files files (so $total in total)."
[[ $ign -gt 0 ]] && echo " >> With $ign ignored items (of '$ignore').."

if [[ $err -gt 0 ]]; then
	echo -en " >> With $err errors.. as follows:"
	echo "$errFiles" >&2
fi

