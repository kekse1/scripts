#!/usr/bin/env bash

######################################################################
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.4.6
#
# This will transfer all NEW/CHANGES files via `rsync` command,
# using the SSH protocol.
#
######################################################################
#

# _important_ config: from which path the relative $DIR path (see below)?
# => 0 for this script's directory, 1 for current working directory
# ALTERNATIVELY define your own directory prefix here..
FROM="0"
# first configuration
DIR="sync"
USER="user"
SRC="/home/sync/"
SRV="host"
PORT="22"

# determine this path, so calling from anywhere is possible w/o using $PWD or so..
real="$(realpath "$0")"
dir="$(dirname "$real")"
base="$(basename "$real")"

# check the current command line for this script..
force=0
verbose=0
linux=0
dereference=0
changed=0
short=fvldh
long=force,verbose,linux,dereference,help
opts="$(getopt -o "$short" -l "$long" -n "$base" -- "$@")"

if [[ $? -ne 0 ]]; then
	#echo -e " >> Unable to parse command line arguments (with \`getopt\`)!" >&2
	exit 1
else
	eval set -- "$opts"
fi

while true; do
	case "$1" in
		'-f'|'--force')
			echo " >> -f/--force will start \`rsync\` without asking user to confirm it."
			force=1
			changed=1
			shift
			;;
		'-v'|'--verbose')
			echo " >> -v/--verbose enables verbose \`rsync\` output."
			verbose=1
			changed=1
			shift
			;;
		'-l'|'--linux')
			echo " >> -l/--linux enables file permissions, attributes and symlinks.. otherwise ignored."
			linux=1
			changed=1
			shift
			;;
		'-d'|'--dereference')
			echo " >> -d/--dereference will resolve symbolic links."
			dereference=1
			changed=1
			shift
			;;
		'-h'|'--help')
			echo "    Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>"
			echo "                  https://kekse.biz/"
			echo "                  https://github.com/kekse1/scripts/"
			echo
			echo " >> Syntax: $(basename "$0")"
			echo "    [ -f / --force ]"
			echo "    [ -v / --verbose ]"
			echo "    [ -l / --linux ]"
			echo "    [ -d / --dereference ]"
			echo "    [ -h / --help ]"
			exit
			;;
		'--')
			shift
			break
			;;
		#*)
		#	echo " >> Invalid parameter '$1'!" >&2
		#	exit 254
		#	;;
	esac
done

# after changing smth. via command line, please add empty line after the state outputs (above)
[[ $changed -ne 0 ]] && echo

# the `rsync` command line to use (without paths; see below)
CMD="rsync --archive --checksum --recursive --relative --rsh='ssh -p${PORT}' --progress --fsync --compress"

# --linux/-l option..
[[ $linux -eq 0 ]] && CMD="${CMD} --no-owner --no-group --no-perms --no-acls --no-xattrs --no-links"

# --dereference/-d will resolve symlinks and copy real targets themselves
[[ $dereference -ne 0 ]] && CMD="${CMD} --copy-links"

# append --verbose rsync parameter, if wished by user (via cmdline, see above)
[[ $verbose -ne 0 ]] && CMD="${CMD} --verbose"

# be sure directories are ending with path separator.. not necessary, but beautiful. ^_^
[[ "${DIR:(-1)}" == "/" ]] || DIR="${DIR}/"
[[ "${SRC:(-1)}" == "/" ]] || SRC="${SRC}/"

# check $FROM.. and $DIR.. to resolve to one $TRGT
# => 0 for this script's directory, 1 for current working directory
TRGT=

if [[ "$FROM" == "0" ]]; then
	TRGT="${dir}"
elif [[ "$FROM" == "1" ]]; then
	TRGT="`pwd`"
else
	TRGT=""
fi

TRGT="$(realpath "${TRGT}/${DIR}/")"

# check if target directory exists (or if it's a directory),
# or create this one here.
if [[ -e "$TRGT" ]]; then
	if [[ ! -d "$TRGT" ]]; then
		echo " >> Target directory exists, but ain't a directory! Exiting.." >&2
		exit 2
	else
		touch "${TRGT}/.keep"
	fi
else
	mkdir -p "$TRGT"

	if [[ $? -eq 0 ]]; then
		echo " >> Target directory has just been created!"
		touch "${TRGT}/.keep"
	else
		echo " >> Target directory could NOT be created! Exiting.." >&2
		exit 3
	fi
fi

# paths appended to command line
CMD="${CMD} ${USER}@${SRV}:\"${SRC}\" \"${TRGT}\""

# show kinda summary, just to info..
echo " >> Your command line is as follows:"
echo "   \`$CMD\`"
echo

# function to repeatly ask user until y/n are his answer..
askUser()
{
	local cont; while true; do
		read -p " >> Do you want to continue [Yes|No]? " cont

		case "${cont,,}" in
			y*) return 0;;
			n*) return 1;;
			*) echo -e " >> Invalid input, try again (with 'y' or 'n')." >&2;;
		esac
	done
}

# call the function above only if not defined -f/--force for this script
if [[ $force -eq 0 ]]; then
	askUser

	if [[ $? -eq 0 ]]; then
		echo -e " >> Great, so we're going to start the \`rsync\` now..\n"
	else
		echo " >> OK, we're aborting right here, script will do nothing else." >&2
		exit 255
	fi
fi

# DO IT!
eval "$CMD"
ret=$?
echo -en "\n\n.. returned ($ret). "
[[ $ret -eq 0 ]] && echo -e "... (0) \033[1m:-)\033[0m" || echo -e "... ($ret) \033[1m:-(\033[0m"

