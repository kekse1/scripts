#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/
# v0.1.0
#
# TODO # unbedingt noch ein prompt <yes/no>!
# TODO # bestenfalls noch eine optional GLOB maske, z.b. "*.tar"!
#

echo "Creating [ \`sha512sum\`, \`b2sum\` ] for current directory:"
echo -e "\t`pwd`\n"
count=0

for i in *; do
	[[ -f "$i" ]] || continue
	echo -ne "\t$i ... "
	sha512sum "$i" >"${i}.sha512"
	[[ $? -ne 0 ]] && exit 1
	b2sum "$i" >"${i}.b2"
	[[ $? -ne 0 ]] && exit 2
	echo "done."
	((++count))
done

echo -e "\nDone, for ${count} _files_ in total."

