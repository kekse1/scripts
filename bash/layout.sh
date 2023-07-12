#!/usr/bin/env bash
#
# (c) Sebastian Kucharczyk <kuchen@kekse.biz>
#
# Requirement: `apt install x11-xkb-utils`
#
# The most important thing for me was to switch between (configurable, see down below)
# keyboard layouts - easily with a shortcut I've set up in XFCE (Settings -> Keyboard):
# calling this script with '-' argument only (so traversing, *not* setting..)!
#
# I'm not using the 'de' layout because the 'us' layout is much better @ Linux & Coding.
#

layouts=("us" "de")

#
if [[ $# -eq 0 ]]; then
	setxkbmap -query | tail -n1 | awk '{print $2}'
elif [[ $# -eq 1 ]]; then
	if [[ "$1" = "-" ]]; then
		current="$(setxkbmap -query | tail -n1 | awk '{print $2}')"
		next=""

		for ((i=0; i<${#layouts[@]}; i++)); do
			if [[ "${layouts[$i]}" = "$current" ]]; then
				next="${layouts[$(((i+1)%${#layouts}))]}"
				break
			fi
		done

		if [[ -n "$next" ]]; then
			setxkbmap -layout "$next" 2>/dev/null
			res=$?

			if [[ $res -ne 0 ]]; then
				echo " >> Couldn't change layout to '$next' ($res).." >&2
				exit 3
			else
				echo " >> Changed layout to '$next'."
			fi
		else
			echo " >> Error with your \$layouts[]" >&2
			exit 4
		fi
	else
		setxkbmap -layout "$1" 2>/dev/null
		res=$?

		if [[ $res -ne 0 ]]; then
			echo " >> Couldn't change layout to '$1' ($res)." >&2
			exit 2
		fi
	fi
else
	echo " >> Syntax: $(basename "$0") [ <layout> / - ]" >&2
	exit 1
fi

