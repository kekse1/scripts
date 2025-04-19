#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.0
#
# My own solution (instead of using `autossh` or so).
#
# Kinda 'watchdog', w/ pause between retries. For some
# reverse ssh tunnel. Default configuration opens the
# port (2222) on your remote machine - as a relay/tunnel
# to your local SSH server (so without port forwarding).
#
# Use <Ctrl>+<C> to create a SIGINT signal, which will
# stop this script (via `trap`).
#

#
_port_remote=22
_port_local=22
_port_tunnel=1024
_host_remote="localhost"
_host_local="localhost"
_sleep=1m

#
sigint()
{
	echo "Received SIGINT (<Ctrl>+<C>), so we exit here." >&2
	exit
}

trap sigint SIGINT

#
_count=1
echo "Starting SSH reverse tunnel."
while true; do

	ssh -p${_port_remote} -N -R ${_port_tunnel}:${_host_local}:${_port_local} ${_host_remote} #-f

	let _count=$_count+1
	echo -n "Restarting SSH reverse tunnel #${_count}... "

	if [[ -z $_sleep || $_sleep -eq 0 ]]; then
		echo "now."
	else
		echo "in ${_sleep}."
		sleep $_sleep
	fi

done

#

