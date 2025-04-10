#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.1
# 
# Renames a bunch of files in a directory (NOT recursive)
# with an increasing number (counted for each file extension),
# surely obeying the original extension.
#
# This was necessary for me after sorting out duplicates of
# some files w/ my older `index.sh` (which perfectly fits to
# this one - maybe you want to use both together? ;-) ...
#
# So also take a look at my older `index.sh`!
# Both together are better. :-)
#

#
# TODO # ...
#
# # dynamic extension (each w/ own counter)
# # optional prefix and suffix!
#

#
# HERE you can set default values.. but they'll get overriden
# in case your defining 'em via command line (see -h/--help)!
#
PREFIX=""
SUFFIX=""
GLOBAL=0
HIDDEN=0
FULL=0

# 
SOURCE=""
TARGET=""

#
real="$(realpath "$0")"
dir="$(dirname "$real")"
#base="$(basename "$real")"
base="$(basename "$0")"

#
syntax()
{
	echo "Syntax: $0 < source directory > < target directory >"; echo
	echo -e "\t        [ --help / -h ]  Just shows this syntax information ONLY"
	echo -e "\t[ --prefix <...> / -p ]  Optional string *before* count value"
	echo -e "\t[ --suffix <...> / -s ]  Optional string *after* count value"
	echo -e "\t      [ --hidden / -d ]  Include hidden/dot files"
	echo -e "\t        [ --full / -f ]  Takes full extensions"
	echo -e "\t      [ --global / -g ]  ONE counter instead of one for each extension"
	echo
}

#
short='hp:s:dfg'
long='help,prefix:,suffix:,hidden,full,global'
opts="$(getopt -o "$short" -l "$long" -n "$base" -- "$@")"

if [[ $? -ne 0 ]]; then
	#echo ...
	exit 1
else
	eval set -- "$opts"
fi

while true; do
	case "$1" in
		'-h'|'--help')
			syntax
			exit
			;;
		'-g'|'--global')
			[[ $GLOBAL -eq 0 ]] && GLOBAL=1 || GLOBAL=0
			shift;
			;;
		'-f'|'--full')
			[[ $FULL -eq 0 ]] && FULL=1 || FULL=0
			shift
			;;
		'-H'|'--hidden')
			[[ $HIDDEN -eq 0 ]] && HIDDEN=1 || HIDDEN=0
			shift
			;;
		'-p'|'--prefix')
			shift
			if [[ -z "$1" ]]; then
				echo 'Missing `--prefix` parameter!' >&2
				exit 2
			fi
			PREFIX="$1"
			shift
			;;
		'-s'|'--suffix')
			shift
			if [[ -z "$1" ]]; then
				echo 'Missing `--suffix` parameter!' >&2
				exit 3
			fi
			SUFFIX="$1"
			shift
			;;
		'--')
			shift
			break
			;;
	esac
done

if [[ -n "$1" && -d "$1" ]]; then
	SOURCE="$1"
elif [[ -z "$SOURCE" || ! -d "$SOURCE" ]]; then
	echo "Missing or invalid source directory!" >&2
	exit 4
fi

if [[ -n "$2" && -d "$2" ]]; then
	TARGET="$2"
elif [[ -z "$TARGET" || ! -d "$TARGET" ]]; then
	echo "Missing or invalid target directory!" >&2
	exit 5
fi

SOURCE="$(realpath "$SOURCE")"
TARGET="$(realpath "$TARGET")"

echo "[Source] '$SOURCE'"
echo "[Target] '$TARGET'"

#
prompt()
{
	local prompt
	read -p "$*" prompt
	prompt="${prompt::1}"
	prompt="${prompt,,}"
	[[ "$prompt" == "y" ]] && return 0
	return 1
}

#
if [[ "$SOURCE" == "$TARGET" ]]; then
	echo -e "\nYour source directory is the same as your target." >&2
	prompt "Are you sure this is correct [yes/no]? "
	if [[ $? -ne 0 ]]; then
		echo -e "OK, so we abort here.." >&2
		exit 6
	fi
	echo
fi

echo -e "[Source] '$SOURCE'"
echo -e "[Target] '$TARGET'"
echo -e "[Prefix] '$PREFIX'"
echo -e "[Suffix] '$SUFFIX'"
echo -n "[Hidden] "; [[ $HIDDEN -eq 0 ]] && echo "no" || echo "yes"
echo -n "[Global] "; [[ $GLOBAL -eq 0 ]] && echo "no" || echo "yes"
echo -n "  [Full] "; [[ $FULL -eq 0 ]] && echo "no" || echo "yes"
echo;

#
extname1()
{
	local result="$(basename "$*")"
	result=".${result#*.}"
	echo "$result"
}

extname2()
{
	local result="$(basename "$*")"
	result=".${result##*.}"
	echo "$result"
}

extname()
{
	[[ $FULL -eq 0 ]] && extname2 "$*" || extname1 "$*"
}

#
FIND="find '$SOURCE' -maxdepth 1 -type f"
[[ $HIDDEN -eq 0 ]] && FIND+=" -not -name '.*'"
FIND+=" -print0"

FILES=()
declare -A COUNT

#
while IFS= read -r -d '' file; do
	FILES+=( "$file" )
	EXT="$(extname "$file")"
	COUNT[$EXT]=$((COUNT["$EXT"]+1))
done < <(eval "$FIND")

#
echo -e "\n(TODO)\n\nExtensions found, btw:\n"
for ext in "${!COUNT[@]}"; do
	echo "[$ext] ${COUNT[$ext]}"
done
echo -e "\n(TODO) as already set.. exiting!"; exit 255


# 
# TODO #
#
# erstmal eine uebersicht ueber die extensions und ihre zaehlungen anzeigen..
# dann fragen, ob das so ok ist? inkl. die anzeige aller gefundenden files, btw..!!1
#
# und dann alle durchlaufen und jeweils *KOPIEREN* in's $TARGET verzeichnis..! ^_^
#
# bedenke: `for ext in "${!COUNT[@]}"; ...`! ;-)
#

