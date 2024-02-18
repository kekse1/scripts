#!/usr/bin/env bash

######################################################################
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# v0.0.7
#
# This will transfer all NEW/CHANGES files via `rsync` command,
# using the SSH protocol.
#
######################################################################
# To be exact @ my family: our archive will be synchronized right here
# with my USB stick I leave there for you.. ^_^
######################################################################
#

# first configuration
DIR="sync"
USER="sync"
SRC="/home/sync/"
SRV="sync.ssh.server"
PORT="22"

# check the current command line for this script..
force=n
verbose=y
changed=n

for i in "$@"; do
	case "$i" in
		-f|--force)
			echo " >> -f/--force will start \`rsync\` without asking user to confirm it."
			force=y
			changed=y
			;;
		-v|--verbose)
			echo " >> -v/--verbose enables verbose \`rsync\` output."
			verbose=y
			changed=y
			;;
		-?|--help)
			echo "    Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>" >&2
			echo " >> Want some help? Please.. read the fucking source! xD~" >&2
			exit
			;;
	esac
done

# after changing smth. via command line, please add empty line after the state outputs (above)
[[ "$changed" == "y" ]] && echo

# the `rsync` command line to use (without paths; see below)
CMD="rsync --archive --checksum --recursive --relative --rsh='ssh -p${PORT}' --progress --fsync"

# append --verbose rsync parameter, if wished by user (via cmdline, see above)
[[ "$verbose" == "y" ]] && CMD="${CMD} --verbose"

# determine this path, so calling from anywhere is possible w/o using $PWD or so..
real="$(realpath "$0")"
dir="$(dirname "$real")"

# be sure directories are ending with path separator.. not necessary, but beautiful. ^_^
[[ "${DIR:(-1)}" == "/" ]] || DIR="${DIR}/"
[[ "${SRC:(-1)}" == "/" ]] || SRC="${SRC}/"

# paths appended to command line
CMD="${CMD} ${USER}@${SRV}:${SRC} ${dir}/${DIR}"

# check if target directory exists (or if it's a directory),
# or create this one here.
if [[ -e "${dir}/${DIR}" ]]; then
	if [[ ! -d "${dir}/${DIR}" ]]; then
		echo " >> Target directory exists, but ain't a directory! Exiting.." >&2
		exit 1
	fi
else
	mkdir -p "${dir}/${DIR}"

	if [[ $? -eq 0 ]]; then
		echo " >> Target directory has just been created!"
		touch "${dir}/${DIR}/.keep"
	else
		echo " >> Target directory could NOT be created! Exiting.." >&2
		exit 2
	fi
fi

# show kinda summary, just to info..
echo " >> Your command line is defined as follows:"
echo "   '$CMD'"
echo

# function to repeatly ask user until y/n are his answer..
askUser()
{
	while true; do
		read -p " >> Do you want to continue [Yes|No]? " cont

		case "${cont,,}" in
			y*) return 0;;
			n*) return 1;;
			*) echo -e " >> Invalid input, try again (with 'y' or 'n')." >&2;;
		esac
	done
}

# call the function above only if not defined -f/--force for this script
if [[ "$force" != "y" ]]; then
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
[[ $ret -eq 0 ]] && echo ':-)' || echo ':-('

