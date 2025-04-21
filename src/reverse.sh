#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.4.2
#
# My own solution (instead of using `autossh` or so).
#
# Kinda 'watchdog', w/ pause between retries. For some
# reverse ssh tunnel. Default configuration opens the
# port on your remote machine - as a relay/tunnel to
# your local servers (without NAT w/ port forwarding).
#
# Use <Ctrl>+<C> to create a SIGINT signal, which will
# stop this script (via `trap`).
#
# Now also multiple routes possible.
#

# ssh settings for remote host
_port_remote=22
_host_remote="host"
_user_remote="user"
_compress=0
_TCPKeepAlive=yes
_ServerAliveInterval=30
_ConnectTimeout=30
_GatewayPorts=yes
# important: use arrays, due to possibly multiple routes
_host_local=( localhost localhost )
_port_local=( 22 80 )
_port_tunnel=( 2222 8080 )
# the watchdog's $_sleep can be zero length/none.. but not recommended.
_date="%A, %Y-%m-%d (%H:%M:%S)"
_sleep=2m

#
CMD="ssh -p${_port_remote} ${_user_remote}@${_host_remote} -o ConnectTimeout=${_ConnectTimeout} -o ServerAliveInterval=${_ServerAliveInterval} -o TCPKeepAlive=${_TCPKeepAlive} -o ExitOnForwardFailure=yes -o GatewayPorts=${_GatewayPorts} -N "
[[ $_compress -ne 0 ]] && CMD+="-C "

#
len=${#_port_local[@]}
if [[ ${#_port_tunnel[@]} -ne $len || ${#_host_local[@]} -ne $len ]]; then
	echo "Invalid configuration (size mismatch)!" >&2
	exit 1
elif [[ $len -eq 0 ]]; then
	echo "No reverse tunnel configured!" >&2
	exit 2
fi

for (( i=0; i<len; ++i )); do
	host="${_host_local[$i]}"
	port="${_port_local[$i]}"
	tunnel="${_port_tunnel[$i]}"

	echo "${host}:${port} <= ${_host_remote}:${tunnel}"
	CMD+="-R ${tunnel}:${host}:${port} "
done

CMD="${CMD:: -1}"

#
sigint()
{
	echo -e "\nReceived SIGINT (<Ctrl>+<C>), so we exit here." >&2
	exit
}

trap sigint SIGINT

#
_count=1
echo -e "\nStarting SSH reverse tunnel:"
echo -e "\t\`${CMD}\`\n"

while true; do
	date +"${_date}"
	echo; eval "$CMD"; echo
	let _count=$_count+1
	echo -n "Restarting SSH reverse tunnel #${_count}... "

	if [[ -z $_sleep ]]; then
		echo "now."
	else
		echo "in ${_sleep}."
		sleep $_sleep
	fi
done

#

