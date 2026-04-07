#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/
#
# TINY helper.. I'm not even describing it on the README.md.
# 
#

#
iface="enp5s0" # [ enp5s0, wlp6s0 ];
[[ -n "$2" ]] && iface="$2"
dhcp=0

#
[[ "$1" == "UP" ]] && dhcp=1

#
echo "Interface: $iface"
echo -n "     DHCP: "

if [[ $dhcp -eq 0 ]]; then
	echo "no"
else
	echo "yes"
fi

echo

#
if [[ "$1" == "up" || "$1" == "UP" ]]; then
	echo "Shutting UP"
	sudo ip link set dev "$iface" up
	[[ $dhcp -ne 0 ]] && sudo dhclient "$iface"
elif [[ "$1" == "down" || "$1" == "DOWN" ]]; then
	echo "Shutting DOWN"
	sudo ip link set dev "$iface" down
else
	echo "Syntax: \$0 < UP / up / down > [ < iface > ]" >&2
	echo
	echo "Example interfaces: [ 'enp5s0', 'wlp6s0' ];"
	echo "And w/ 'UP' (upper case) we're also using DHCP."
	echo
	exit 1
fi

