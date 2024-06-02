#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.2
#
# Some time ago I needed to setup my computer as a router (using `iptables`).
#
# This was created very quickly, without much features or tests.
# Feel free to use it as kinda template; the following link got more inf0.
#
# https://wiki.gentoo.org/wiki/Home_router
#

#
export LAN="eno1"
export WAN="enp0s20f0u1u3"

# `/etc/init.d/iptables save`
# `rc-update add iptables default`
# `vi /etc/sysctl.conf`:
# >> net.ipv4.ip_forward = 1
# >> net.ipv4.conf.default.rp_filter = 1
# >> net.ipv4.ip_dynaddr = 1

#
if [[ -z "$LAN" ]]; then
	echo " >> '\$LAN' unavailable!" >&2
	exit 2
fi

if [[ -z "$WAN" ]]; then
	echo " >> '\$WAN' unavailable!" >&2
	exit 3
fi

IPTABLES="`which iptables 2>/dev/null`"

if [[ -z "$IPTABLES" ]]; then
	echo " >> \`iptables\` not found!" >&2
	exit 1
fi

#
flushRules()
{
	$IPTABLES -F
	$IPTABLES -t nat -F
}

defaultPoliciesForUnmatchedTraffic()
{
	$IPTABLES -P INPUT ACCEPT
	$IPTABLES -P OUTPUT ACCEPT
	$IPTABLES -P FORWARD DROP
}

lockServices()
{
	$IPTABLES -I INPUT 1 -i $LAN -j ACCEPT
	$IPTABLES -I INPUT 1 -i lo -j ACCEPT
	$IPTABLES -A INPUT -p UDP --dport bootps ! -i $LAN -j REJECT
	$IPTABLES -A INPUT -p UDP --dport domain ! -i $LAN -j REJECT
}

allowSSH()
{
	$IPTABLES -A INPUT -p TCP --dport ssh -i $WAN -j ACCEPT
}

dropUnprivileged()
{
	$IPTABLES -A INPUT -p TCP ! -i $LAN -d 0/0 --dport 0:1023 -j DROP
	$IPTABLES -A INPUT -p UDP ! -i $LAN -d 0/0 --dport 0:1023 -j DROP
}

nat()
{
	$IPTABLES -I FORWARD -i $LAN -d 192.168.0.0/16 -j DROP
	$IPTABLES -A FORWARD -i $LAN -s 192.168.0.0/16 -j ACCEPT
	$IPTABLES -A FORWARD -i $WAN -d 192.168.0.0/16 -j ACCEPT
	$IPTABLES -t nat -A POSTROUTING -o $WAN -j MASQUERADE
}

informKernel()
{
	echo 1 >/proc/sys/net/ipv4/ip_forward

	for i in /proc/sys/net/ipv4/conf/*/rp_filter; do
		echo 1 >$i
	done
}

#
if [[ "$1" == "flush" ]]; then
	echo " >> Flushing rules..."
	flushRules
	exit
fi

echo " >> Making your host a NAT router..."

flushRules
defaultPoliciesForUnmatchedTraffic
lockServices
allowSSH
dropUnprivileged
nat
informKernel

echo -e " >> DONE. \e[1m:-)\e[0m"

