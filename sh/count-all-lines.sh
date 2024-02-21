#!/bin/bash
# 
# tiny helper script (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.0
#
# Would be helpful to argue with quoted globals, so the shell doesn't resolve 'em!
# Otherwise, just escape all '*' with '\'.
# 
# (TODO) .. would be interesting to count lines w/o comments; but for that
# I've made another script (to extract various comments).
#

inames=

for i in "$@"; do
	inames="${inames}
$i"
done
inames="${inames:1}"

if [[ -z "$inames" ]]; then
	echo " >> Please give me one or more '-iname' files as parameters." >&2
	echo " >> If using '*' globs, please quote them," >&2
	echo " >> or just escape any '*' with '\'." >&2
	exit 1
fi

cmd="find -L -type f"
IFS=$'\n'

for i in "$inames"; do
	cmd="${cmd} -iname '$i'"
done

cmd="${cmd} 2>/dev/null | xargs wc -l | sort -n"
echo -e "   '$cmd':\n\n"
eval "$cmd"

