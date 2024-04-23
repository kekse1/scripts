#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.2
#
# Start streaming.. I use it for the "BigFM Nightlounge".
# You can add this to your /etc/crontab. :-)
#

#
URL="https://streams.bigfm.de/bigfm-deutschland-128-mp3"
NAME="Nightlounge"
EXT=".mp3"
DURATION="130m"
DATE="%A, %F"
PID="wget.pid"

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
echo -e "\n\n\nGoing to \`kill -9 ${pid}\` in ${DURATION}!\n\n\n"

trap "cleanUp $pid" INT
sleep $DURATION && cleanUp $pid

#

