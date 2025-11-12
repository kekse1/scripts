#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.1
#
# Kinda tiny "management" of exit and it's codes. ...
#
# So the plain `quit` function will use either a counted
# exit code (see below @ `quits`) or a random one (see
# below @ `rand`) if none is specified as first argument,
# or if [[ $1 == "+" ]]; ...
#
# The `rand` will be used then to return a pure *random*
# exit code between [ 1 .. 255 ].
#
# And the (most important) `quits` function can be called
# by you (or by `quit` if first parameter equals "++"!)
# any time you do *not* exit in your bash shell scripts
# but want to (++) count the next exit code to use l8rs.
#
# So the reason is: every error case in my scripts should
# exit with a next exit code. And I got tired of counting
# them on my own - so e.g. when I inserted another one
# somewhere above, I had to shift all following ones (to
# keep it *really* clean..); etc.
#
# Now you can just call `quits` for every possible error
# where you don't exit (so this error was false). And if
# l8rs some error occurs, you just have to `quits ++` or
# smth. like it. ;-)
#
# So, this is a really simple script. But I wouldn't want
# to miss such logics right now (after many own scripts).
# ^_^
#

quit()
{
	local ret=$1
	
	if [[ "$ret" == "+" ]]; then
		ret=$(rand 255 1)
	elif [[ "$ret" == "++" ]]; then
		quits; ret=$?
	elif [[ -z "$ret" ]]; then
		[[ $QUIT -gt 0 ]] && ret=$QUIT || ret=$(rand 255 1)
	fi

	[[ $# -ge 2 ]] && return $ret
	exit $ret
}

rand()
{
	local max=$1; [[ -z "$max" ]] && max=4294967295 # now the max. int32 ((2**32)-1) or ((256**4)-1);
	local min=$2; [[ -z "$min" ]] && min=0

	if [[ $max -eq $min ]]; then
		echo $max; return $max; fi
	if [[ $max -lt $min ]]; then
		local tmp=$max
		max=$min
		min=$tmp
	fi

	local result=$(((RANDOM%(max-min+1))+min))
	echo $result; return $result;
}

export QUIT=0; quits()
{
	((++QUIT))
	[[ $QUIT -gt 255 ]] && QUIT=1
	return $QUIT
}

