#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.0
#

#
SERVER="de.pool.ntp.org"
#LOG="/var/log/ntpdate.sh.log"
LOG=""

#
ntp="`which ntpdate 2>/dev/null`"; [[ $? -ne 0 ]] && exit 1
hwc="`which hwclock 2>/dev/null`"

if [[ -z "$LOG" ]]; then
	$ntp $SERVER
	[[ -n "$hwc" ]] && $hwc --systohc
else
	$ntp $SERVER >"$LOG" 2>&1
	[[ -n "$hwc" ]] && $hwc --systohc >>"$LOG" 2>&1
fi

