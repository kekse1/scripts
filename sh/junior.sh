#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
#
# Handling the `llama.cpp` (or rather `node-llama-cpp`) better.
#
# Put your prompts into './prompts/*txt'.
#
# Put your models into './models/*.gguf'.
# You should store the original filenames to identify 'em better, but you NEED
# to create symbolic links with easier key names to use them in here!
#
# Configure the 'default_context' variable below.
#
# Running this script with less than two arguments will show a short sytax help message.
#

#
default_context="16384"

#
real="$(realpath "$0")"
prefix="$(dirname "$real")"
prefix="$(realpath "$prefix/../")"
self="$(basename "$real")"

#
syntax()
{
	echo " >> Syntax: $self <model> <prompt> [ <context size> ]" >&2
}

invalidArguments()
{
	syntax
	listModels
	listPrompts
	echo
}

listModels()
{
	echo -e "\n >> Available models:\n" >&2
	for i in $prefix/models/*; do
		[[ ! -L $i ]] && continue
		echo " >> \`$(basename "$i" .gguf)\`"
	done
}

listPrompts()
{
	echo -e "\n >> Available prompts:\n" >&2
	for i in $prefix/prompts/*.txt; do
		echo " >> \`$(basename "$i" .txt)\`"
	done
}

#
threads="`nproc 2>/dev/null`"
threads="4"

if [[ -z "$threads" ]]; then
	echo " >> Unable to determine number of CPU threads." >&2
	exit 1
fi

#
model="$1"
modelPath=""

if [[ -z "$model" ]]; then
	invalidArguments
	exit 2
elif [[ ! -f "${prefix}/models/${model}" ]]; then
	echo " >> The model \`$model\` couldn't be found!" >&2
	exit 3
else
	modelPath="${prefix}/models/${model}"
fi

#
prompt="$2"
promptData=""

if [[ -z "$prompt" ]]; then
	invalidArguments
	exit 4
elif [[ ! -f "${prefix}/prompts/${prompt}.txt" ]]; then
	echo " >> The prompt \`$prompt\` couldn't be found!" >&2
	exit 5
else
	promptData="`cat ${prefix}/prompts/${prompt}.txt`"
fi

#
context="$3"

if [[ -z "$context" ]]; then
	context="$default_context"
fi

#
_npx="`which npx 2>/dev/null`"

if [[ -z "$_npx" ]]; then
	echo " >> Unable to determine your \`npx\` (of Node.js).." >&2
	exit 6
fi

#
echo -e "\n< https://kekse.biz/#~nlp >\n"
echo -e "Context size: $context\n       Model: \`$model\`\n      Prompt: \`$prompt\`\n\n"

#
cd "$prefix" && npx --no node-llama-cpp chat \
	--systemPrompt "$promptData" \
	--model "$modelPath" \
	--threads $threads \
	--contextSize $context
	#--prompt "$promptData"

# 
# and see the node_examples, and also compare the models/..!!!
#

