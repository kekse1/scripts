#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.2
#
# Tiny helper; maybe copy it to /etc/profile.d/fresh.sh
#

fresh()
{
	txt="`date +'[%s%N] %A, %Y-%m-%d (%H:%M:%S)'`"
	[[ $# -gt 0 ]] && txt="$txt: $*"

	git pull
	git add --all
	git commit -m "$_txt"
	git push
}

