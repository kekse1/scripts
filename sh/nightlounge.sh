#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.5
#
# Start streaming.. I use it for the "BigFM Nightlounge".
# You can add this to your /etc/crontab. :-)
#
# New since v0.2.3: you can optionally start this script
# with a `sleep` parameter (e.g. "25m") to delay the stream
# recording for a while.. so if you start this before
# midnight, it'll wait until it'll finally start the stream.
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

OUT="`date +\"$DATE\"`"
[[ -n "$NAME" ]] && OUT="${NAME} (${OUT})"
ORIG="$OUT"
count=0

while [[ -f "${OUT}${EXT}" ]]; do
	let count=$count+1
	OUT="${ORIG} (${count})"
done

OUT="${OUT}${EXT}"
echo " >> Output file: '$OUT'"

#
if [[ $# -gt 0 ]]; then
	echo
	echo " >> Now we're waiting for the clock until we record the stream: '$1'..."
	sleep "$1"
	if [[ $? -ne 0 ]]; then
		echo "Error!" >&2
		exit 2
	fi
fi

#
cleanUp()
{
	pid="$1"
	[[ -z "$pid" ]] && pid="`cat $PID`"
	kill -9 $pid >/dev/null 2>&1
	rm "$PID"
	ls -ahl "$OUT"
	ls -al "$OUT"
	echo -e "\n\n"
}

#
wget -O "$OUT" "$URL" &
pid="$!" #pid="`ps aux | grep wget | grep "$_out" | awk '{print $2}'`"
echo -n "$pid" >"$PID"
echo -e "\n\n >> Going to \`kill -9 ${pid}\` in ${DURATION}!\n\n\n"

trap "cleanUp $pid" INT
sleep $DURATION && cleanUp $pid

#

