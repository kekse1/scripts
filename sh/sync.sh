#!/usr/bin/env bash

######################################################################
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.0
#
# This will transfer all NEW/CHANGES files via `rsync` command,
# using the SSH protocol.
#
######################################################################
#

# _important_ config: from which path the relative $DIR path (see below)?
# => 0 for this script's directory, 1 for current working directory
# IF $DIR IS NO ABSOLUTE PATH OR BEGINS WITH './' OR '../'!!
# important since e.g. cronjobs would not have to be called with
# special current working directory.. etc. ;-)
FROM=0

# first configuration
DIR="sync"
USER="sync"
SRC="/home/sync/"
SRV="ssh.rsync.server.host"
PORT="22"

# check the current command line for this script..
force=n
verbose=n
perms=n

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
		-p|--perms)
			echo " >> -p/--perms enables file permissions, otherwise ignored."
			perms=y
			changed=y
			;;
		-?|--help)
			echo "    Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>"
			echo -e "\n >> Syntax: \$0 [ -f / --force // -v / --verbose // -p / --perms ]"
			exit
			;;
	esac
done

# after changing smth. via command line, please add empty line after the state outputs (above)
[[ "$changed" == "y" ]] && echo

# the `rsync` command line to use (without paths; see below)
CMD="rsync --archive --checksum --recursive --relative --rsh='ssh -p${PORT}' --progress --fsync"

# --perms/-p option..
[[ "$perms" == "y" ]] && CMD="${CMD} --no-owner --no-group --no-perms"

# append --verbose rsync parameter, if wished by user (via cmdline, see above)
[[ "$verbose" == "y" ]] && CMD="${CMD} --verbose"

# determine this path, so calling from anywhere is possible w/o using $PWD or so..
real="$(realpath "$0")"
dir="$(dirname "$real")"

# be sure directories are ending with path separator.. not necessary, but beautiful. ^_^
[[ "${DIR:(-1)}" == "/" ]] || DIR="${DIR}/"
[[ "${SRC:(-1)}" == "/" ]] || SRC="${SRC}/"

# check $FROM.. and $DIR.. to resolve to one $TRGT
TRGT=

if [[ "${DIR::1}" == "/" || "${DIR::2}" == "./" || "${DIR::3}" == "../" ]]; then
	TRGT="$(realpath "$DIR")"
elif [[ "$FROM" -eq 0 ]]; then
	TRGT="${dir}/${DIR}"
else
	TRGT="$(realpath "$DIR")"
fi

# paths appended to command line
CMD="${CMD} ${USER}@${SRV}:${SRC} ${TRGT}"

# check if target directory exists (or if it's a directory),
# or create this one here.
if [[ -e "$TRGT" ]]; then
	if [[ ! -d "$TRGT" ]]; then
		echo " >> Target directory exists, but ain't a directory! Exiting.." >&2
		exit 1
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

