#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/
# v0.1.0
#

#
LENGTH=4
PREFIX="phrack_"
CONCAT=""

#
real="$(realpath "$0")"
dir="$(dirname "$real")"

#
if [[ -z "$LENGTH" || $LENGTH -le 0 ]]; then
	echo "ERROR: Invalid \$LENGTH configuration!" >&2
	exit 1
elif [[ "$PREFIX" =~ "/" ]]; then
	echo "ERROR: Invalid \$PREFIX configuration (no valid prefix string)!" >&2
	exit 2
fi

#
if [[ -z "$1" || -z "$2" ]]; then
	echo -e "\n >> Syntax: \$0 < source directory > < target directory > [ < concat target file > ]\n" >&2
	echo -e "The < concat > is optional. ... for even more training (for Norbert) preparation." >&2
	echo -e "There are, btw., some other settings - so please also look at the top of this script." >&2
	exit 255
fi

[[ -n "$3" ]] && CONCAT="$3"

if [[ -n "$CONCAT" ]]; then
	CONCAT="$(realpath "$CONCAT" 2>/dev/null)"

	if [[ $? -ne 0 ]]; then
		echo "Invalid concat target file!" >&2
		exit 3
	fi
fi

SOURCE="$(realpath "$1" 2>/dev/null)"

if [[ $? -ne 0 ]]; then
	echo "Invalid source directory!" >&2
	exit 4
elif [[ ! -d "$SOURCE" ]]; then
	echo "Source directory doesn't exist (as directory)!" >&2
	exit 5
fi

TARGET="$(realpath "$2" 2>/dev/null)"

if [[ $? -ne 0 ]]; then
	echo "Invalid target directory!" >&2
	exit 6
elif [[ ! -d "$TARGET" ]]; then
	echo "Target directory doesn't exist (as directory)!" >&2
	exit 7
fi

while [[ "${SOURCE: -1}" == "/" ]]; do
	SOURCE="${SOURCE::-1}"
done
while [[ "${TARGET: -1}" == "/" ]]; do
	TARGET="${TARGET::-1}"
done

echo -e "    Number padding: ${LENGTH}"
echo -e "  Directory prefix: '${PREFIX}'"

echo -e "  Source directory: ${SOURCE}/"
echo -e "  Target directory: ${TARGET}/"

if [[ -z "$CONCAT" ]]; then
	echo -e "Concat target file: -/-"
else
	echo -e "Concat Target file: ${CONCAT}"
fi; echo

#
cd "$TARGET"
_count=0

while true; do
	((++_count))
	_phrack="${SOURCE}/phrack${_count}.tar.gz"

	if [[ ! -f "$_phrack" ]]; then
		((--_count))
		echo -e "Reached the end, with issue (${_count})."
		break
	fi

	str="$_count"
	while [[ ${#str} -lt $LENGTH ]]; do
		str="0${str}"
	done

	mkdir "${PREFIX}${str}"

	if [[ $? -ne 0 ]]; then
		echo "Unable to create directory "${PREFIX}${str}"!" >&2
		exit 8
	else
		cd "${PREFIX}${str}"
	fi

	tar -xf "$_phrack"

	if [[ $? -ne 0 ]]; then
		echo "Unable to extract source file '${_phrack}' (issue ${_count})!" >&2
		exit 9
	fi

	for i in *.txt; do
		base="$(basename "$i" .txt)"

		while [[ "${#base}" -lt $LENGTH ]]; do
			base="0${base}"
		done

		[[ "$i" == "${base}.txt" ]] && continue
		mv "$i" "${base}.txt"

		if [[ $? -ne 0 ]]; then
			echo "UNABLE to rename the file '$i' (in issue ${_count})! ABORTING here.. ;-/" >&2
			exit 10
		fi
	done

	cd "$TARGET"
done
echo "Prepared ${_count} issues for training your Norbert! :-)"

if [[ -z "$CONCAT" ]]; then
	echo "NOT going to concat everything.. so we're DONE here! :-D"
	exit
fi

CONCAT_BASE="$(basename "$CONCAT")"
CONCAT_TEMP="/tmp/${RANDOM}${RANDOM}${RANDOM}${RANDOM}.tmp"

if [[ -e "$CONCAT_TEMP" ]]; then
	echo "I really didn't expect this.. please try again! xD~" >&2
	exit 11
fi

echo; echo "NOW we're using the \`concat.sh\` logics to combine all into one. ..."
find . -iname '*.txt' -print0 | sort -z | xargs -0 cat >"$CONCAT_TEMP"
mv "$CONCAT_TEMP" "$CONCAT"

if [[ $? -ne 0 ]]; then
	echo "FAILED to concat everything..! :-/" 2>&1
	exit 12
fi

echo "Full success! Everything's done ..."
echo "All issues are collected in one text/plain concat file:"
echo -e "\t'${CONCAT}'"
echo "MAYBE you should delete all the other files in your target directory:"
echo -e "\t'${TARGET}'"
echo

