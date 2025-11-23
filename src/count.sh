#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.1
#
# You can copy this file to your '/etc/profile.d/' dir.
# It does *not* need to be executable - it's `source`d.
#
# Four functions to count fs entries:
#
#	  F()	files
#	  D()	directories
#	  L()	symbolic links
#	  A()	all entries in directory
#	[ C()	the base function. better coding.. ]
#
# Either without any parameter. Will count all files
# in the current directory (only).
#
# Possible first parameter is the -maxdepth, to also
# include the sub directory tree. (1) is my default;
# but this can be changed in this file (below).
#
# A second an more parameter(s) should be integrated
# in the `find` command line, so they need to fit to
# this command.
#
# Example given: `f 1 -iname '*.js'`
#
# PS: Usually I'm using `ls | wc -l`, but it's "bad".
#

# Maybe you'd like to change the default -maxdepth
_maxdepth=1

#
function C()
{
	local type="$1"; local count="$2"; local depth="$3"
	shift; shift; shift; [[ -z "$depth" ]] && depth=$_maxdepth
	cmd="find -maxdepth $depth -mindepth 1 -type $type"
	for i in "$@"; do cmd+=" '$i'"; done
	[[ $count -ne 0 ]] && cmd+=" | wc -l"
	eval "$cmd" #; echo "\`$cmd\`"
}

function F()
{
	C f 1 $@
}

function D()
{
	C d 1 $@
}

function L()
{
	C l 1 $@
}

function A()
{
	echo $((`F`+`D`+`L`))
}

