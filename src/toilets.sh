#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.2
#
# Calls `toilet` (see '_toilet' below, e.g. for changing to `figlet`)
# multiple times by using a font list file (each font own line). So
# you can easily compare them.
#
# You can define other parameters we pass through to `figlet` by
# using '-' or '--' switches. Any regular argument will be used
# for the input text. If nothing found in the command line, you'll
# get asked for your input.
#

#
_toilet="`which toilet 2>/dev/null`"

if [[ -z "$_toilet" ]]; then
	echo " >> The \`toilet\` was not found." >&2
	exit 1
fi

#
_list="$1"
shift
_text=""
_args=""

for i in "$@"; do
	if [[ "${i:0:1}" == "-" ]]; then
		_args="${_args} $i"
	else
		_text="${_text} $i"
	fi
done

_args="${_args:1}"
_text="${_text:1}"

if [[ -z "$_list" ]]; then
	echo " >> First parameter needs to be a font list file!" >&2
	exit 2
elif [[ ! -r "$_list" ]]; then
	echo " >> No readable file '$_list' found!" >&2
	exit 3
elif [[ -z "$_text" ]]; then
	echo -e " >> Input your output text, now:\n"

	read _text

	if [[ -z "$_text" ]]; then
		echo " >> No text specified!" >&2
		exit 4
	fi

	echo -e "\n\n\n\n"
fi

#
IFS=$'\n'
for f in `cat "$_list"`; do
	_cmd="echo '$_text' | $_toilet -f '$f' $_args"
	echo -e "\e[1m\e[4m$f\e[0m\n"
	eval "$_cmd"
	echo -e "\n\n\n"
done

#

