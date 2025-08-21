#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.3.2
#
# Easily use the `hfdownloader` tool, from:
# https://github.com/bodaay/HuggingFaceModelDownloader
# You can download it via:
# bash <(curl -sSL https://g.bodaay.io/hfd) -h
#
# Syntax: $0 [ <model> [ <params> [ ... ] ] ]
#
# Please adapt the following variables to your needs.
#
# TODO: a LIST of models to download..
#

#
CONCURRENT=4
TOKEN="token.txt" #a file!
TOOL="./hfdownloader"
ARGS="--maxRetries 64 --retryInterval 16 --concurrent 10"

#
real="$(realpath "$0")"
dir="$(dirname "$real")"
cd "$dir"

#
if [[ ! -x "${TOOL}" ]]; then
	echo " >> The '$TOOL' is not available." >&2
	exit 1
fi

if [[ -n "$TOKEN" ]]; then
	if [[ ! -r "$TOKEN" ]]; then
		echo " >> Invalid token file '$TOKEN'." >&2
		exit 2
	fi

	ORIG="$TOKEN"
	TOKEN="`cat $TOKEN`"

	if [[ -z "$TOKEN" ]]; then
		echo " >> Token file '$ORIG' was empty." >&2
		exit 3
	else
		TOKEN="-t '$TOKEN'"
	fi
fi

[[ "${TOOL::1}" != "." && "${TOOL::1}" != "/" ]] && TOOL="./${TOOL}"

#
MODEL=''

if [[ $# -gt 0 ]]; then
	MODEL="$1"
	shift
elif [[ -z "$MODEL" ]]; then
	echo " >> No model defined!" >&2
	exit 4
fi

if [[ "$MODEL" != *:* ]]; then
	if [[ $# -gt 0 ]]; then
		MODEL="${MODEL}:$1"
		shift
		for i in "$@"; do
			MODEL="${MODEL},$i"
		done
	fi
fi

#
cmd="${TOOL} $TOKEN -c${CONCURRENT} -m '${MODEL}' ${ARGS}"

#
echo -e "Command: "$cmd"\n\n"
eval "$cmd"
ret=$?
echo -e "\n\n"
[[ $ret -eq 0 ]] && echo -e " ... (0) \e[1m:-)\e[0m" || echo -e " ... ($ret) \e[1m:-(\e[0m"

