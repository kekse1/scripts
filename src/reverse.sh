#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.3.0
#
# My own solution (instead of using `autossh` or so).
#
# Kinda 'watchdog', w/ pause between retries. For some
# reverse ssh tunnel. Default configuration opens the
# port (1024) on your remote machine - as a relay/tunnel
# to your local SSH server (so without port forwarding).
#
# Use <Ctrl>+<C> to create a SIGINT signal, which will
# stop this script (via `trap`).
#

#
_port_remote=22
_port_local=22
_port_tunnel=1024
_host_remote="remote.host"
_host_local="localhost"
_date="%A, %Y-%m-%d (%H:%M:%S)"
_sleep=1m

#
sigint()
{
	echo -e "\nReceived SIGINT (<Ctrl>+<C>), so we exit here." >&2
	exit
}

trap sigint SIGINT

#
_count=1
echo "Starting SSH reverse tunnel."

while true; do

	date +"${_date}"

	echo
	ssh -p${_port_remote} -o ExitOnForwardFailure=yes -N -R ${_port_tunnel}:${_host_local}:${_port_local} ${_host_remote} #-f
	echo

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

