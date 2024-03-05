#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.2
#
# Starting with a shell script (to be `source`d) for
# ANSI escape sequences.
#
# Not much in here, but maybe a base for more? But
# one can nevertheless use it right now, in this way:
#
# $ echo "ein `bold`test`none`; `fg 150 240 0`worx`none`."
#
# You either need to manually `source` or `.` in your shell
# (it's NOT executable), or copy it to `/etc/profile.d/ansi.sh`.
#

none()
{
	echo -en "\e[0m"
}

bold()
{
	echo -en "\e[1m"
}

fg()
{
	echo -en "\e[38;2;$1;$2;$3m"
}

bg()
{
	echo -en "\e[48;2;$1;$2;$3m"
}
