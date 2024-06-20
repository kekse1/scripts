#!/bin/bash
# 
# tiny helper script (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.3.2
# 
# Syntax: $0 <-iname> [ ... ]
# 
# Parameters especially to define filename globs (which are used case *in*-sensitive).
# IMPORTANT: if you're using GLOBs, e.g. for file extension masks, please ENQUOTE or
# ESCAPE them (mostly any '*')!
# 
# (TODO) .. would be interesting to count lines w/o comments; but for that
# I've made another script (to extract various comments).
# 

real="$(realpath "$0")"
dir="$(dirname "$real")"
base="$(basename "$real")"

short=h
long=help
opts="$(getopt -o "$short" -l "$long" -n "$base" -- "$@")"

if [[ $? -eq 0 ]]; then
	eval set -- "$opts"
else
	exit 1
fi

inames=

while true; do
	case "$1" in
		'-h'|'--help')
			echo "Syntax: $(basename "$0") < iname/glob > [ ... ]" >&2
			exit
			;;
		'--')
			shift
			break
			;;
	esac
done

for i in "$@"; do
	inames="${inames} -o -iname '$i'"
done

inames="${inames:4}"

if [[ -z "$inames" ]]; then
	echo " >> Please give me one or more '-iname' files as parameters." >&2
	echo " >> If using '*' globs, please quote them," >&2
	echo " >> or just escape any '*' with '\'." >&2
	exit 1
fi

cmd="find -L -type f $inames"
cmd="${cmd} 2>/dev/null | xargs wc -l | sort -n"
echo -e "   '$cmd':\n\n"
eval "$cmd"

