#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/
# v0.1.1
#
# TODO!!!°1^1 .. ist eine vorbereitung auf mein `norbert`-training.
# 	... und der wunsch, sowas gutes selbst zu mirror'en. ^_^
#

_source="https://archives.phrack.org/tgz/"

#
_target=""

if [[ -z "$_target" ]]; then
	if [[ -z "$1" ]]; then
		echo "Syntax: \$0 < target directory >" >&2
		exit 1
	fi

	_target="$1"
fi

_target="$(realpath "$_target" 2>/dev/null)"

if [[ $? -ne 0 ]]; then
	echo "Invalid target directory!" >&2
	exit 2
fi

if [[ ! -d "$_target" ]]; then
	echo "Target directory doesn't exist (as directory)!" >&2
	exit 3
fi

while [[ "${_source: -1}" == "/" ]]; do
	_source="${_source::-1}"
done

echo -e "Downloading into: ${_target}"
echo -e "     From source: ${_source}/"
echo; echo

#
cd "$_target"
_res=0; _count=0

while true; do
	((++_count))
	wget -c "${_source}/phrack${_count}.tar.gz"
	_res=$?

	if [[ $_res -eq 0 ]]; then
		echo -e "\n\n\tDownloaded issue #${_count}!\n\n"
	else
		echo -e "\n\n\tUnable to download #${_count}!" >&2
		echo -e "\tCheck if this is really the end of available issues." >&2
		((--_count))
		echo -e "\tSo we have ${_count} issues now.\n\n"
		exit $_res
	fi
done

