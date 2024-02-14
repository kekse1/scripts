#!/bin/bash
# 
# tiny helper script (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# 
# just copy to /usr/local/bin/.. maybe.
#
# (TODO) .. would be interesting to count lines w/o comments; but for that
# I've made another script (to extract various comments).
#

if [[ -z "$1" ]]; then
	echo -e "Please give me a file glob, like '*.js'.." >&2
	exit 1
fi

find -L . -iname "$1" -type f 2>/dev/null | xargs wc -l | sort -n

