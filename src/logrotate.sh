#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.2
#
# Simple setup for log line entries.
#
# See the `syntax()` help: you can append new log lines to a file, and you
# can optionally limit the line count to a specific value.
#
# With defined line limit parameter (or manually by calling `LOG_CLEAN()`),
# only this amount of lines will be enforced in the log file; whereas they
# are counted from the end of file (so with (3) only the last three lines
# will stay in the log file).
#
# *Really* easy setup.. :-)
#

#
LOG()
{
	syntax()
	{
		echo -e "Syntax:\n\tLOG <file> <limit> ... <line>" >&2
		echo -e "\nIf line (limit <= 0), there'll be NO limit at all." >&2
	}

	if [[ $# -lt 3 ]]; then syntax; return 1; fi

	local LINES="$1"; if [[ -z "$LINES" ]]; then
		syntax; return 2; fi

	local FILE="$1"; if [[ -z "$FILE" ]]; then
		echo -e "[ERROR] No file argument given.\n" >&2
		syntax; return 3
	elif [[ ! -e "$FILE" ]]; then
		touch "$FILE"; if [[ $? -ne 0 ]]; then
			echo -e "[ERROR] Target file couldn't be \`touch\`ed.\n" >&2
			syntax; fi
	elif [[ ! -f "$FILE" ]]; then
		echo -e "[ERROR] Output path is no real file.\n" >&2
		syntax; return 4; fi
	
	shift; local LINES="$1"; if [[ -z "$LINES" ]]; then
		echo -e "[ERROR] No line limit defined.\n" >&2
		syntax; return 5; fi

	shift; local LINE="$*"; [[ -z "$LINE" ]] && return 3

	echo "$LINE" >>$FILE
	[[ $LINES -gt 0 ]] && LOG_CLEAN "$FILE" "$LINES"
}

LOG_CLEAN()
{
	local FILE="$1"; if [[ -z "$FILE" ]]; then
		echo "[ERROR] No file argument given." >&2
		return 1; fi
	local LINES="$2"; if [[ -z "$LINES" ]]; then
		echo "[ERROR] No line argument given." >&2
		return 2; fi
	[[ $LINES -le 0 ]] && return
	local lines=$(wc -l <"$FILE")
	[[ "$lines" -le "$LINES" ]] && return
	sed -i "1,$((lines - LINES))d" "$FILE"
}

