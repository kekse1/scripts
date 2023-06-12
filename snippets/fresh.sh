#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
#
# Tiny helper.. copy to /etc/profile.d/.
#

fresh()
{
	_txt="`date +'%s%N'`"
	[ $# -gt 0 ] && _txt="$_txt ($*)"

	git pull
	git add --all
	git commit -m "$_txt"
	git push
}

