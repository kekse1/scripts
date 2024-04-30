#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.5
#
# Easily use the `hfdownloader` tool, from:
# https://github.com/bodaay/HuggingFaceModelDownloader
# You can download it via:
# bash <(curl -sSL https://g.bodaay.io/hfd) -h
#
# Syntax: $0 [ <model> [ <params> [ ... ] ] ]
#
# Please adapt the following variables to your needs.
# And see the following link for `.gguf` conversion:
# https://github.com/ggerganov/llama.cpp/discussions/2948
#

#
CONCURRENT=6
TOKEN="" #"token.txt" #a file!
TOOL="./hfdownloader"
ARGS=""

#
DEFAULT_MODEL="" #mistralai/Mixtral-8x22B-v0.1"
DEFAULT_PARAM="" #e.g. "q4_0,q5_0"

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
elif [[ -z "$MODEL" && -n "$DEFAULT_MODEL" ]]; then
	MODEL="${DEFAULT_MODEL}"
else
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
	elif [[ -n "$DEFAULT_PARAM" ]]; then
		MODEL="${MODEL}:${DEFAULT_PARAM}"
	fi
fi

#
cmd="${TOOL} $TOKEN -c${CONCURRENT} -m '${MODEL}'"
[[ -n "$ARGS" ]] && CMD="${CMD} ${ARGS}"

#
echo -e "Command: "$cmd"\n\n"
eval "$cmd"
ret=$?
echo -e "\n\n"
[[ $ret -eq 0 ]] && echo -e " ... (0) \e[1m:-)\e[0m" || echo -e " ... ($ret) \e[1m:-(\e[0m"

