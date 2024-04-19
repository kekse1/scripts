#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.1
#
# Easily use the `hfdownloader` tool, from:
# https://github.com/bodaay/HuggingFaceModelDownloader
# You can download it via:
# bash <(curl -sSL https://g.bodaay.io/hfd) -h
#
# Please adapt the following variables to your needs.
# The first $MODEL will be set by your arguments. Or
# just use the default one, you can even set it below.
#
# And see the following link for `.gguf` conversion:
# https://github.com/ggerganov/llama.cpp/discussions/2948
#

#
PARAM="" # e.g. "q4_0,q5_0"
CONCURRENT=8
TOKEN="token.txt"
TOOL="./hfdownloader"

#
DEFAULT="mistralai/Mixtral-8x22B-v0.1"

#
orig="`pwd`"
real="$(realpath "$0")"
dir="$(dirname "$real")"

cd "$dir"

#
MODEL=''

if [[ $# -gt 0 ]]; then
	MODEL="$*"
elif [[ -z "$MODEL" ]]; then
	MODEL="$DEFAULT"
fi

#
if [[ ! -x "${TOOL}" ]]; then
	echo " >> The '$TOOL' is not available." >&2
	exit 1
fi

if [[ ! -r "${TOKEN}" ]]; then
	echo " >> Invalid token file." >&2
	exit 2
else
	TOKEN="`cat ${TOKEN}`"
fi

[[ "${TOOL::1}" != "." && "${TOOL::1}" != "/" ]] && TOOL="./${TOOL}"

#
cmd="${TOOL} -t '$TOKEN' -c${CONCURRENT} -m '${MODEL}:${PARAM}'"
eval "$cmd"

#
cd "$orig"
