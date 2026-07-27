#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.3.3
#
# Start streaming.. I use it for the "BigFM Nightlounge".
# You can add this to your /etc/crontab. :-)
#
# If you're using my own `asleep` < https://github.com/kekse1/asleep/ >,
# it'll enhance the functionality a bit. I also added the `+` parameter
# (or an empty string) to start directly at 00:00:01. ;-)
#

#
URL="https://streams.bigfm.de/bigfm-deutschland-128-mp3"
NAME="Nightlounge"
EXT=".mp3"
DURATION="130m"
DATE="%A, %F"
PID="wget.pid"

#
echo " >> Your stream: '$URL'"

#
if [[ -f "$PID" ]]; then
	echo " >> Streaming is already running (PID = `cat \"$PID\"`)." >&2
	exit 1
elif [[ "${EXT::1}" != "." ]]; then
       	EXT=".${EXT}"
fi

#
if [[ $# -gt 0 ]]; then
	_str=" >> Now we're waiting for the clock until we record the stream"
	_param="$1"

	_asleep="`which asleep 2>/dev/null`"
	_sleep="`which sleep 2>/dev/null`"

	if [[ -n "$_asleep" ]]; then
		echo " >> Cool! The extended \`asleep\` was found! Using it now.."

		if [[ -z "$_param" || "$_param" == "+" ]]; then
			_param="1@"
			echo -e "${_str} at 00:00:01 am"
		else
			echo -e "${_str}: '${_param}'"
		fi
	elif [[ -n "$_sleep" ]]; then
		echo -e "${_str}: '${_param}'"
	else
		echo " >> ERROR: Can't use neither \`asleep\` not \`sleep\`"
		exit 4
	fi

	if [[ -n "$_asleep" ]]; then
		echo; $_asleep -v -- "$_param" || exit 2
	else
		$_sleep -- "$_param" || exit 3
	fi
fi

#
OUT="`date +\"$DATE\"`"
[[ -n "$NAME" ]] && OUT="${NAME} (${OUT})"
ORIG="$OUT"
count=0

while [[ -f "${OUT}${EXT}" ]]; do
	((++count))
	OUT="${ORIG} (${count})"
done

OUT="${OUT}${EXT}"
echo " >> Output file: '$OUT'"

#
cleanUp()
{
	local pid="$1"
	[[ -z "$pid" ]] && pid="`cat $PID`"
	kill -9 $pid >/dev/null 2>&1
	rm "$PID"
	echo; echo
	ls -ahl "$OUT"
	ls -al "$OUT"
	echo -e "\n\n"
	trap - INT
}

#
wget -O "$OUT" "$URL" &
pid="$!" #pid="`ps aux | grep wget | grep "$_out" | awk '{print $2}'`"
echo -n "$pid" >"$PID"
echo -e " >> Going to \`kill -9 ${pid}\` in ${DURATION}!\n\n\n"

trap "cleanUp $pid" INT
sleep $DURATION && cleanUp $pid

#

