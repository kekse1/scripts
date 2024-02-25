#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.2
#
# A little helper to `scp` files, with only the remote file path as argument.
#
# I'm using this to copy backups from my server, most because on errors this
# is going to repeat the copy (as long you define in the 'loops' variable).
# So just set your server {user,host,port} and copy securely.
#
# BTW: yes, I had an unstable line when I created this.. via mobile phone.
#

#
user="USER"
host="HOST"
port="22"

timeout=30	# set to 0 or lower to disable...
loops=8		# set to 0 or lower to disable this feature.
existsWarn=1	# warning if file already exists; otherwise will be deleted.

#
if [[ -z "$user" ]]; then
	echo " >> Your configuration is invalid (here the 'user' is unset)." >&2
	exit 199
elif [[ -z "$host" ]]; then
	echo " >> Your configuration is invalid (here the 'host' is unset)." >&2
	exit 198
elif [[ -z "$port" ]]; then
	port="22"
fi

if [[ -z "$timeout" ]]; then
	timeout=30
fi

if [[ -z "$loops" ]]; then
	loops=0
fi

#
file="$*"

if [[ -z "$file" ]]; then
	echo " >> Syntax: $(basename "$0") < file >" >&2
	exit 1
else
	echo " >> File to copy: '$file'"
	echo " >> Copying from: '$user@$host'"
fi

#
_res=255
_loops=0
_reached_max=0

stop()
{
	echo
	echo " >> SIGINT (loops: $_loops)"
	exit $_res
}

trap "stop" INT

#
cmd="-P$port $user@$host:\"$file\" ./"

if [[ $timeout -le 0 ]]; then
	cmd="scp $cmd"
else
	cmd="scp -o ConnectTimeout=$timeout $cmd"
fi

#
#base="$(basename "$file")"
#cmd="ssh $user$host \"cat $file\" | cat - >\"$base\""

#
base="$(basename "$file")"

#
if [[ $existsWarn -ne 0 && -e $base ]]; then
	echo " >> As you configured me to warn you: the file '$base' already exists!" >&2
	exit 100
else
	rm "$base" 2>/dev/null
fi

#
echo " >> Command: '$cmd'"
echo

#
while [[ $_res -ne 0 ]]; do
	let _loops=$_loops+1
	echo
	echo " >> Loop #$_loops"
	echo
	eval "$cmd"
	_res=$?

	if [[ $_res -ne 0 ]]; then
		rm "$base" 2>/dev/null

		if [[ $? -ne 0 ]]; then
			echo " >> The error seems to be that the file doesn't exist." >&2
			echo " >> So we're aborting here, instead of trying $loops times.." >&2
			exit 200
		elif [[ $_loops -ge $loops ]]; then
			_reached_max=$_loops
			break;
		fi
	fi
done

echo
echo
if [[ $_reached_max -gt 0 ]]; then
	echo " >> ABORT (after $_reached_max loops)" >&2
else
	echo " >> DONE (after $_loops loops)"
fi
echo " >> Command was: '$cmd'"
echo

exit $_res
