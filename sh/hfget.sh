#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.0
#
# Just a tiny helper, if you don't want to use the `hfdownloader(.sh)`.
#
# Downloads from Hugging Face (https://huggingface.co/) with your
# own Token (a file) included in the HTTP request header. This
# massively increases the speed of your downloads (and maybe more).
#
# Depends on the `wget` command/tool (will be checked).
# Will NOT download with multiple/parallel connections!
#

#
TOKEN="token.txt"

#
WGET="$(which wget 2>/dev/null)"

if [[ -z "$WGET" ]]; then
	echo " >> Your \`wget\` couldn't be found!" >&2
	exit 2
elif [[ -z "$1" ]]; then
	echo " >> Please argue with a URL or a file of URLs." >&2
	exit 1
fi

#
real="$(realpath "$0")"
dir="$(dirname "$real")"

#
if [[ -r "$TOKEN" ]]; then
	TOKEN="$(cat "$TOKEN")"
elif [[ -r "$dir/$TOKEN" ]]; then
	TOKEN="$(cat "$dir/$TOKEN")"
else
	echo " >> No token file found! But we'll continue nevertheless.." >&2
	TOKEN=""
fi

#
cmd="$WGET --continue"

if [[ -f "$1" ]]; then
	cmd="${cmd} --input-file='$1'"
else
	cmd="${cmd} '$1'"
fi

#
echo " >> OK, here we go (as follows; token not printed here):"
echo "   \`$cmd\`"
echo

#
[[ -n "$TOKEN" ]] && cmd="${cmd} --header='Authorization: Bearer ${TOKEN}'"

#
eval "$cmd"

