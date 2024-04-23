#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/
# v0.0.3
#
# https://github.com/ggerganov/llama.cpp/discussions/2948
#
# This script helps you converting hugging face models (see
# https://huggingface.co/) to GGUF format (.gguf), which is
# necessary for the transformers I listed on my website @
# https://kekse.biz/?~intelligence ...
#
# Dependencies:
#
# # Python (witn `pip`)
# # llama.cpp (seebelow)
#
# Preparations:
#
# $ python3 -m venv venv
# $ cd venv && source bin/activate
# $ git clone https://github.com/ggerganov/llama.cpp.git
# $ ./bin/pip install -r llama.cpp/requirements.txt
# $ python llama.cpp/convert.py -h
#

#
TYPE="f32" # f32, f16, q8_0, .. # 'f' preserve original quali
MODELS="downloads"
FORMAT="gguf"
LLAMA="venv/llama.cpp"
PYTHON="python3"

#
real="$(realpath "$0")"
dir="$(dirname "$real")"

#
[[ "${MODELS::1}" != "/" ]] && MODELS="${dir}/${MODELS}"

if [[ ! -d "$MODELS" ]]; then
	echo " >> Model path doesn't exist (as directory)." >&2
	exit 1
fi

#
MODEL=

if [[ $# -gt 0 ]]; then
	MODEL="$1"
	echo " >> Selected model: '$MODEL'"

	if [[ $# -gt 1 ]]; then
		TYPE="$2"
		echo " >> Target type: '$TYPE'"
	fi
else
	cd "$MODELS" 2>/dev/null

	if [[ $? -ne 0 ]]; then
		echo " >> Can't open model directory." >&2
		exit 2
	fi

	for i in *; do
		[[ -d "$i" ]] || continue
		[[ -f "$i/config.json" ]] || continue
		echo " >> $i"
	done

	exit
fi

[[ "${FORMAT::1}" != "." ]] && FORMAT=".${FORMAT}"
[[ "${LLAMA::1}" != "/" ]] && LLAMA="${dir}/${LLAMA}"
CONVERT="${LLAMA}/convert.py"

if [[ ! -r "$CONVERT" ]]; then
	echo " >> Your \`convert.py\` isn't existing/readable!" >&2
	exit 3
elif [[ "${PYTHON::1}" != "/" ]]; then
	PYTHON="`which $PYTHON 2>/dev/null`"
	if [[ -z "$PYTHON" ]]; then
		echo " >> Your python binary was not found." >&2
		exit 4
	fi
fi

#
cd "$MODELS" 2>/dev/null

if [[ $? -ne 0 ]]; then
	echo " >> Can't open model directory." >&2
	exit 5
fi

if [[ ! -d "$MODEL" ]]; then
	echo " >> Your model '$MODEL' isn't available!" >&2
	echo " >> For a list of available ones, run this script without parameters." >&2
	exit 6
fi

#
CMD="'$PYTHON' '$CONVERT' '${MODEL}' --outtype ${TYPE} --outfile='${MODEL}${FORMAT}'"
echo -e " >> Command: \"$CMD\"\n"
eval "$CMD"
res="$?"
echo -e "\n\n"
[[ $res -eq 0 ]] && echo -e "... (0) \e[1m:-)\e[0m" || echo -e "... ($res) \e[1m:-(\e[0m"

