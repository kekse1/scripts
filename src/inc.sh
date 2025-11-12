#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.3
# 
# Renames a bunch of files in a directory (NOT recursive)
# with an increasing number. With some options..
#
# This was necessary for me after sorting out duplicates of
# some files w/ my older `index.sh` (which perfectly fits to
# this one - maybe you want to use both together? ;-) ...
#
# So also take a look at my older `index.sh`!
# Both together are better. :-)
#

#
# STILL ONLY TODO!1
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
PRESERVE=0
REMOVE=0

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
	echo -e "\t      [ --hidden / -d ]  Also count hidden/dot files (w/ \`.\` prefix)"
	echo -e "\t        [ --full / -f ]  Takes full extensions"
	echo -e "\t      [ --global / -g ]  ONE counter instead of one for each extension"
	echo -e "\t    [ --preserve / -v ]  Do not use any --prefix/--suffix (only original name)"
	echo -e "\t      [ --remove / -r ]  Remove count of file names; only already counted w/ --preserve"
	echo -e "\t        [ --sort / -t ]  Used by \`ls\` - that\'s how files will get counted"
	echo
}

#
short='ht:p:s:dfgvr'
long='help,sort:,prefix:,suffix:,hidden,full,global,preserve,remove'
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
		'-t'|'--sort')
			shift
			if [[ -z "$1" ]]; then
				echo 'Missing `--sort` parameter!' >&2
				exit 2
			fi
			SORT="$1"
			shift
			;;
		'-v'|'--preserve')
			[[ $PRESERVE -eq 0 ]] && PRESERVE=1 || PRESERVE=0
			shift;
			;;
		'-r'|'--remove')
			[[ $REMOVE -eq 0 ]] && REMOVE=1 || REMOVE=0
			shift;
			;;
		'-g'|'--global')
			[[ $GLOBAL -eq 0 ]] && GLOBAL=1 || GLOBAL=0
			shift;
			;;
		'-f'|'--full')
			[[ $FULL -eq 0 ]] && FULL=1 || FULL=0
			shift
			;;
		'-d'|'--hidden')
			[[ $HIDDEN -eq 0 ]] && HIDDEN=1 || HIDDEN=0
			shift
			;;
		'-p'|'--prefix')
			shift
			if [[ -z "$1" ]]; then
				echo 'Missing `--prefix` parameter!' >&2
				exit 3
			fi
			PREFIX="$1"
			shift
			;;
		'-s'|'--suffix')
			shift
			if [[ -z "$1" ]]; then
				echo 'Missing `--suffix` parameter!' >&2
				exit 4
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
	exit 5
fi

if [[ -n "$2" && -d "$2" ]]; then
	TARGET="$2"
elif [[ -z "$TARGET" || ! -d "$TARGET" ]]; then
	echo "Missing or invalid target directory!" >&2
	exit 6
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
		exit 7
	fi
	echo
fi

_preserve_remove=0

if [[ $PRESERVE -ne 0 ]]; then
	if [[ -n "$PREFIX" || -n "$SUFFIX" ]]; then
		_preserve_remove=1
		echo "JFYI: I'm disabling the --prefix/--suffix due to --preserve." >&2
	fi

	PREFIX=''
	SUFFIX=''
fi

echo -e "  [Source] '$SOURCE'"
echo -e "  [Target] '$TARGET'"
echo -en "  [Prefix] '$PREFIX'"; [[ $_preserve_remove -ne 0 ]] && echo -n " (removed due to --preserve)"; echo
echo -en "  [Suffix] '$SUFFIX'"; [[ $_preserve_remove -ne 0 ]] && echo -n " (removed due to --preserve)"; echo
echo -n "  [Hidden] "; [[ $HIDDEN -eq 0 ]] && echo "no" || echo "yes"
echo -n "  [Global] "; [[ $GLOBAL -eq 0 ]] && echo "no" || echo "yes"
echo -n "    [Full] "; [[ $FULL -eq 0 ]] && echo "no" || echo "yes"
echo -n "[Preverse] "; [[ $PRESERVE -eq 0 ]] && echo "no" || echo "yes"
echo -n "  [Remove] "; [[ $REMOVE -eq 0 ]] && echo "no" || echo "yes"
echo;

#
extname1()
{
	local result="$(basename "$*")"
	while [[ "${result::1}" == "." ]]; do
		result="${result:1}"; done
	[[ -z "$result" ]] && return 1
	[[ "$result" =~ "." ]] || return 2
	result="${result#*.}"
	[[ "${result::1}" == "." ]] && return 3
	echo ".${result}"
}

extname2()
{
	local result="$(basename "$*")"
	while [[ "${result::1}" == "." ]]; do
		result="${result:1}"; done
	[[ -z "$result" ]] && return 1
	[[ "$result" =~ "." ]] || return 2
	result="${result##*.}"
	[[ "${result::1}" == "." ]] && return 3
	echo ".${result}"
}

extname()
{
	if [[ $FULL -eq 0 ]]; then
		extname2 "$*"
		return $?
	fi

	extname1 "$*"
	return $?
}

#
FIND="find '$SOURCE' -maxdepth 1 -type f"
[[ $HIDDEN -eq 0 ]] && FIND+=" -not -name '.*'"
FIND+=" -print0"

count=0
FILES=()
declare -A COUNT

#
while IFS= read -r -d '' file; do
	FILES+=( "$file" )
	ext="$(extname "$file")"
	[[ $? -ne 0 ]] && continue
	[[ -v COUNT["$ext"] ]] || ((++count))
	COUNT["$ext"]=$((COUNT["$ext"]+1))
done < <(eval "$FIND")

#
_max=0
for i in "${!COUNT[@]}"; do
	[[ ${#i} -gt $_max ]] && _max=${#i}
done

echo -e "\nI found and counted ${count} different file extensions:\n"

for ext in "${!COUNT[@]}"; do
	printf "[%${_max}s] %d\n" "$ext" "${COUNT[$ext]}"
done

#
echo -e "\n\n\n... TODO (all the rest).. ^_^\n"
echo -e "\thttps://github.com/kekse1/scripts/\n\t<kuchen@kekse.biz>\n"
exit 127


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

