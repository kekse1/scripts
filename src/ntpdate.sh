#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.3.0
#
# Call it with a path parameter for logging only the last update.
# Without any parameter, either a configured path (below) will be
# used, or none if not configured (then you'll see a direct output).
#
# The $SERVER should always be configured (in here)!
#
# You could also put this in your cronjobs (use `crontab -e`);
# whereas here's my recommendation to argue w/ e.g.
# "/var/log/ntpdate.sh.log".
#

#
SERVER="de.pool.ntp.org"
LOG="" #"/var/log/ntpdate.sh.log"

if [[ -n "$*" ]]; then
	LOG="$*"
fi

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

