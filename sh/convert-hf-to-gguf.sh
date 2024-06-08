#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/
# v0.0.9
#
# This script helps you converting hugging face models (see
# https://huggingface.co/) to GGUF format (.gguf), which is
# necessary for the transformers I listed on my website @
# https://kekse.biz/?~intelligence ...
#
# Syntax: <model> [ <type> [ ... ] ]
#
# If called without parameter, you'll see a list of the
# available models.
#
# And check the configuration variables below this comment!
#
# Dependencies:
#
# # Python 3 (with `pip`)
# # llama.cpp (see below)
#
# Preparations (if not using system's python, see $VENV below):
#
# $ python3 -m venv venv
# $ cd venv
# $ source bin/activate
# $ git clone https://github.com/ggerganov/llama.cpp.git
# $ ./bin/python3 ./bin/pip install -r llama.cpp/requirements.txt
# $ python llama.cpp/convert-hf-to-gguf.py -h
#
# Quantization:
#
# `./llama.cpp/quantize source.gguf target.gguf Q8_0`
#

#
TYPE="q8_0" # f32, f16, q8_0, .. # 'f*' preserves original quality
DOWNLOADS="downloads"
MODELS="models"
FORMAT="gguf"
LLAMA="llama.cpp"
PYTHON="python3"
VENV="venv" # if empty, we use system's python installation
VOCAB="" # 'bpe' necessary for llama3..
ARGS=""

#
real="$(realpath "$0")"
dir="$(dirname "$real")"

#
[[ "${DOWNLOADS::1}" != "/" ]] && DOWNLOADS="${dir}/${DOWNLOADS}"
[[ "${MODELS::1}" != "/" ]] && MODELS="${dir}/${MODELS}"

if [[ ! -d "$DOWNLOADS" ]]; then
	echo " >> DOWNLOAD path doesn't exist (as directory)." >&2
	exit 1
elif [[ ! -d "$MODELS" ]]; then
	echo " >> MODEL path doesn't exist (as directory)." >&2
	exit 2
fi

#
MODEL=''

if [[ $# -gt 0 ]]; then
	MODEL="$1"
	shift
	echo " >> Selected model: '$MODEL'"

	if [[ -n "$1" ]]; then
		TYPE="$1"
		shift
		echo " >> Target type: '$TYPE'"
	fi

	for i in "$@"; do
		ARGS="${ARGS} '$i'"
	done
else
	cd "$DOWNLOADS" 2>/dev/null

	if [[ $? -ne 0 ]]; then
		echo " >> Can't open model directory." >&2
		exit 3
	fi

	for i in *; do
		[[ -d "$i" ]] || continue
		[[ -f "$i/config.json" ]] || continue
		echo " >> $i"
	done

	exit
fi

#
if [[ -n "$VENV" ]]; then
	if [[ "${VENV::1}" != "/" ]]; then
		if [[ "${VENV::2}" == "./" || "${VENV::3}" == "../" ]]; then
			VENV="`pwd`/${VENV}"
		else
			VENV="${dir}/${VENV}"
		fi
	fi
	PYTHON="${VENV}/bin/$(basename "$PYTHON")"
elif [[ "${PYTHON::1}" != "/" ]]; then
	[[ -x "$PYTHON" ]] || PYTHON="`which $PYTHON 2>/dev/null`"
	if [[ -z "$PYTHON" ]]; then
		echo " >> Your python binary was not found." >&2
		exit 4
	fi
fi

#
if [[ "${LLAMA::1}" != "/" ]]; then
	if [[ -z "$VENV" ]]; then
		LLAMA="${dir}/${LLAMA}"
	else
		LLAMA="${VENV}/${LLAMA}"
	fi
fi

[[ "${FORMAT::1}" != "." ]] && FORMAT=".${FORMAT}"
CONVERT="${LLAMA}/convert-hf-to-gguf.py"

if [[ ! -r "$CONVERT" ]]; then
	echo " >> Your \`convert.py\` isn't existing/readable!" >&2
	exit 5
fi

#
if [[ ! -d "${DOWNLOADS}/${MODEL}" ]]; then
	echo " >> Your model '$MODEL' isn't available!" >&2
	echo " >> For a list of available ones, run this script without parameters." >&2
	exit 6
fi

#
CMD="'$PYTHON' '$CONVERT' '${DOWNLOADS}/${MODEL}' --outtype ${TYPE} --outfile='${MODELS}/${MODEL}.${TYPE}${FORMAT}'"
[[ -n "$VOCAB" ]] && CMD="${CMD} --vocab-type '${VOCAB}'"
[[ -n "$ARGS" ]] && CMD="${CMD} ${ARGS}"

echo -e "\`$CMD\`\n\n"
eval "$CMD"
res="$?"
echo -e "\n\n"
[[ $res -eq 0 ]] && echo -e "... (0) \e[1m:-)\e[0m" || echo -e "... ($res) \e[1m:-(\e[0m"

