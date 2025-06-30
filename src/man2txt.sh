#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://norbert.com.es/
# v0.2.0
#
# Conversion of all (compressed) linux man pages (/usr/share/man/)
# into `text/plain` versions. BUT you need a copy of the whole fs
# tree, because original input files are being deleted (so replaced
# by the new ones) [see also "$_unlink"];
#
# Will also create an extra INDEX FILE which lists all pages with
# their names, sections and (new target) file path's.
#
# Symbolic Links stay, but I'm planning to change them to point to
# the new versions. Sooner or later...
#
# Also depends on the `groff` and `col` utilities.
#
# PS: I used my <https://github.com/kekse1/dump.js/> utility `ansi`
# to remove all ANSI escape sequences.. but I thought this was too
# much dependencies, so I decided to only do a short `sed` regular
# expression removement of ANSI escape sequences.. maybe bad? ...
#

#tiny config
_refresh=500 # refresh time (against flickering..);
_unlink=1 # delete old .gz files!? yep. ^_^
# see also <https://github.com/kekse1/scripts/#ansish> ... etc.

#
BASH="`which bash 2>/dev/null`"

if [[ $? -ne 0 ]]; then
	echo "Unable to find the \`bash\` shell!" >&2
	exit 1
fi

#
REAL="$(realpath "$0")"
DIR="$(dirname "$REAL")"
PROJ="$(realpath "${DIR}/../")"
LIB="$(realpath "${DIR}/lib/")"

#
# https://github.com/kekse1/scripts/#ansish
source "${LIB}/ansi.sh" 2>/dev/null

if [[ $? -ne 0 ]]; then
	echo -e "You also need to download on of my helper scripts:"
	echo -e "\thttps://github.com/kekse1/scripts/#ansish"
	exit 14
fi

#
syntax()
{
	echo -e "\n\t`debug``bold`Syntax`none``debug`: $(basename "$0") `error`<`info` input directory `error`> <`warn` output listing `error`>\n"
	INFO "Will find any \``warn`.gz`info`\` man page, to convert it into `error`text/plain`info`."
	WARN "BUT all these input files (and more) will be deleted, so please ..."
	ERROR "COPY your \``warn`/usr/share/man/`error`\``debug`[*]`error` to a temporary path!"
	echo; [[ -n "$1" ]] && exit $1
}

for i in "$@"; do
	[[ "$i" == "-?" || "$i" == "--help" ]] && syntax 0
done

if [[ -z "$1" || -z "$2" ]]; then
	syntax 255
fi

#
GROFF="`which groff 2>/dev/null`"

if [[ $? -ne 0 ]]; then
	ERROR "Unable to find the \``warn`groff`error`\` utility."
	exit 2
fi

COL="`which col 2>/dev/null`"

if [[ $? -ne 0 ]]; then
	ERROR "Unable to find the \``warn`col`error`\` utility."
	exit 13
fi

#
if [[ -z "$1" ]]; then
	ERROR "The manual files need to be copied to a directory you need to give as parameter."
	exit 3
fi

if [[ -z "$1" ]]; then
	ERROR "Please specify the input directory with all man pages files!"
	exit 4
fi

#
resolvePath()
{
	if [[ "${1::1}" == "/" ]]; then
		echo "$(realpath "$1")"
	else
		echo "$(realpath "$2/$1")"
	fi

	return $?
}

#
in="$(resolvePath "$1" "`pwd`")"

if [[ $? -ne 0 ]]; then
	ERROR "Unable to resolve your input directory!"
	exit 5
elif [[ ! -d "$in" ]]; then
	ERROR "This is not an existing directory."
	exit 6
fi

if [[ -z "$2" ]]; then
	ERROR "Please argue with your output/index file as second parameter!"
	exit 7
fi

out="$(resolvePath "$2" "`pwd`")"

if [[ $? -ne 0 ]]; then
	ERROR "Unable to resolve your output file path!"
	exit 8
elif [[ -e "$out" ]]; then
	ERROR "Output file already exists!"
	exit 9
fi

#
confirm()
{
	local result; read result;
	result="${result::1}"
	result="${result,,}"
	[[ "$result" == "y" ]] && return 0
	return 1
}

#
DEBUG "Input directory: \``warn`${in}`debug`\`"
DEBUG "Listing output: \``warn`${out}`debug`\`"

WARN "All \``error`*.gz`warn`\` files below the input directory will be deleted (after conversion)!"
echo -n "`error`Do you really want to continue `debug`[`bold`yes/no`none``debug`]`error`? "
confirm; if [[ $? -ne 0 ]]; then
	ERROR "OK, so we `warn`abort`error` here..`debug`!"
	exit 11
fi

#
INFO "Good. Now give me some time to create my own file index, etc.. `warn`THX!"
DEBUG "I'm only using any \``info`*.gz`debug`\` in \``error`${in}`debug`\`"
echo

#
sectionMaxLen=0
nameMaxLen=0
fileMaxLen=0
sections=()
names=()
files=()
count=0
lastNow=$((`date +'%s%N'`/1000000))
time=0

while IFS= read -r -d '' file; do
	[[ ${#file} -gt $fileMaxLen ]] && fileMaxLen=${#file}
	name="$(basename "$file" .gz)"
	[[ ${#name} -gt $nameMaxLen ]] && nameMaxLen=${#name}
	section="${name##*.}"
	[[ ${#section} -gt $sectionMaxLen ]] && sectionMaxLen=${#section}
	sections+=( "$section" )
	names+=( "${name%.*}" )
	files+=( "$file" )
	let count=$count+1
	now=$((`date +'%s%N'`/1000000))
	delta=$((now-lastNow))
	lastNow=$now
	time=$((time+delta))
	if [[ $time -ge $_refresh ]]; then
		time=0
		echo -en "\r`info`Found `bold``error`${count}`none``info` files `debug`up until now..`none`"
	fi
done < <(find "$in" -type f -iname '*.gz' -print0)
echo -e "\r`info`Found `bold``error`${count}`none``info` files `debug`when search finished.`none`\n"

let sectionMaxLen=$sectionMaxLen+2
INFO "Now I'm inserting the INDEX into the `error`output file`info`! `debug`May need some seconds..`info`!"

for (( i=0; i<count; ++i)); do
	dir="$(dirname "${files[$i]}")"
	base="$(basename "${files[$i]}" .gz)"
	file="${dir}/${base}.txt"
	printf "%-${fileMaxLen}s %${sectionMaxLen}s ${names[$i]}\n" "${file}" "${sections[$i]}" >>"$out"
done

#
cd "$in"
INFO "Starting conversion of your `debug`man pages to `error``bold`text/plain`none``info` files, `warn`now`info`!"
echo

done=0
lastNow=$((`date +'%s%N'`/1000000))
time=0

hideCursor; for (( i=0; i<count; ++i )); do
	file="${files[i]}"
	dir="$(dirname "$file")"
	base="$(basename "$file" .gz)"
	gunzip <"$file" >"${dir}/${base}.tmp1"
	$GROFF -man -Tascii "${dir}/${base}.tmp1" >"${dir}/${base}.tmp2" 2>/dev/null
	cat "${dir}/${base}.tmp2" | sed 's/\x1B\[[0-9;]*[Jmsu]//g' | $COL -bx >"${dir}/${base}.txt" 2>/dev/null
	[[ $_unlink -ne 0 ]] && rm "$file" 2>/dev/null
	rm "${dir}/${base}.tmp1" "${dir}/${base}.tmp2" 2>/dev/null
	let done=$done+1
	now=$((`date +'%s%N'`/1000000))
	delta=$((now-lastNow))
	lastNow=$now
	time=$((time+delta))
	if [[ $time -ge $_refresh ]]; then
		time=0
		progresss $done $count
	fi
done; progresss $count $count; echo; showCursor

#
echo
INFO "Finished: `bold``error`${count}`none``info` files are `warn`converted`info` now. `bold`:-)`none`"
DEBUG "`warn`JFYI`debug`: Kept old `info`symbolic links`debug` (`error`TODO`debug`); maybe they're `bold`dead`none``debug`now.."

