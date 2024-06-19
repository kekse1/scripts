#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.1
#
# My source code needed my (copyright) header when I published it.
# So I created this script, since more than just less files needed
# to be updated..
#
# The usage is merely easy, look at the output when calling this
# script without parameters!
# 
# Use the '-d' or '--delete' parameter to unlink all of this script's
# backup files ('*.BACKUP', or see $BACKUP variable below); and use
# '-r' or '--restore' to restore the original files from their backups.

# Both of the last parameters will only search for matching files,
# so you *also* need to define your extension(s) and maybe the depth.
#

#
# ONE configuration variable here: the SUFFIX for the BACKUP files.
# 
BACKUP="BACKUP"

#
if [[ -z "$BACKUP" ]]; then
	echo "SORRY, your configuration is invalid!" >&2
	exit 254
elif [[ $# -eq 0 ]]; then
	echo "Syntax: $(basename "$0") <ext> [ ... ] [ <depth> ]"
	echo "        [ -d / --delete ]"
	echo "        [ -r / --restore ]"
	echo
	echo "  You should pipe your new header data to this scripts,"
	echo "  by e.g. \`cat header.txt | ./$(basename "$0")\`."
	echo "  Mostly your header file should end with (at least) one '\n'."
	echo
	echo "  Define as many file extensions as you want. These are being"
	echo "  used to filter out the target files, which will be searched in"
	echo "  your current working directory!"
	echo
	echo "  If no <depth> parameter is defined (an integer value greater"
	echo "  than zero), we'll only search in the current depth (1)."
	echo
	echo "  A backup for each file is being created before it's change,"
	echo "  if there's not already one. If so, the whole process is"
	echo "  being aborted! This is done *before* the real write,"
	echo "  so everything is checked before; just to be sure!"
	echo
	echo "  When using '-d / --delete', you also need to argue with"
	echo "  your extensions (and maybe the depth), since we will NOT"
	echo "  just find any backup file in any depth.. need to match!"
	echo
	echo "  Using '-r / --restore' will use the backup files to restore"
	echo "  the original file contents. Backup files will be deleted then."
	echo
	echo "  Your backup files will have the filename suffix '.${BACKUP}',"
	echo "  by configuration (on top of this file, below the top comment)."
	exit
fi

#
short=dr
long=delete,restore
opts="$(getopt -o "$short" -l "$long" -n "$(basename "$0")" -- "$@")"

if [[ $? -ne 0 ]]; then
	exit 254
else
	eval set -- "$opts"
fi

#
OPTS=()
UNLINK=0
RESTORE=0
STOPPED=0

while [[ $# -gt 0 ]]; do
	if [[ $STOPPED -eq 0 ]]; then
		case "$1" in
			'-d'|'--delete')
				UNLINK=1
				;;
			'-r'|'--restore')
				RESTORE=1
				;;
			'--')
				STOPPED=1
				;;
			*)
				OPTS+=( "$1" )
				;;
		esac
	else
		OPTS+=( "$1" )
	fi
	shift
done
			
if [[ $UNLINK -ne 0 && $RESTORE -ne 0 ]]; then
	echo "Please only define one of --restore/-r or --delete/-d!" >&2
	exit 2
elif [[ $UNLINK -ne 0 ]]; then
	echo "You want to delete all the backup files created by this script before."
elif [[ $RESTORE -ne 0 ]]; then
	echo "You want to restore the changed files via the backup files."
fi

DEPTH=1
INAMES=""
EXT=0

for i in "${OPTS[@]}"; do
	if [[ "$i" =~ ^[0-9]+$ ]]; then
		[[ $i -gt 0 ]] && DEPTH=$i
	else
		[[ "${i::1}" == "." ]] && i="${i:1}"
		[[ ${#i} -eq 0 ]] && continue
		in="-o -iname '*."
		if [[ $UNLINK -eq 0 && $RESTORE -eq 0 ]]; then
			in="${in}${i}"
		else
			in="${in}${i}.${BACKUP}"
		fi
		in="${in}'"
		INAMES="${INAMES} ${in}"
		let EXT=$EXT+1
	fi
done
INAMES="${INAMES:4}"

if [[ -z "$INAMES" || $EXT -eq 0 ]]; then
	echo "Your extensions define *nothing* (counting ${EXT})!" >&2
	exit 3
else
	s="s"; [[ $EXT -eq 1 ]] && s=""
	echo "Using ${EXT} extension${s} for the file search."
fi

#
lines=0
DATA=''

if [[ $UNLINK -eq 0 && $RESTORE -eq 0 ]]; then
	if [[ -t 0 ]]; then
		echo "You need to pipe your new header data to this script!" >&2
		echo "So please do e.g. \`cat header.txt | ./$(basename "$0")\`." >&2
		exit 1
	fi

	lines=0
	while read -r line; do
		DATA="${DATA}
$line"
		let lines=$lines+1
	done
	DATA="${DATA:1}"

	if [[ $lines -eq 0 ]]; then
		echo "Your header data is empty!" >&2
		exit 4
	fi
fi

#
if [[ $DEPTH -eq 1 ]]; then
	echo "Only searching for files in the current working directory."
else
	s="s"; [[ $DEPTH -eq 1 ]] && s=""
	echo "Searching for files up to $DEPTH depth${s}, starting in your current working directory."
fi

FILES=()
IFS=$'\n'
CMD="find -type f $INAMES"
for i in `eval "$CMD"`; do
	if [[ $UNLINK -eq 0 && -e "${i}.${BACKUP}" ]]; then
		echo "The file '$(basename "$i")' already got a '.${BACKUP}' file, so we're aborting here!" >&2
		echo "Really *nothing* changed!" >&2
		exit 5
	else
		FILES+=("$i")
	fi
done

if [[ ${#FILES[@]} -eq 0 ]]; then
	echo "NO files matched! So we're stopping here now."
	exit 6
fi

#
a="s"; [[ $lines -eq 1 ]] && a=""
b="s"; [[ ${#FILES[@]} -eq 1 ]] && b=""
if [[ $UNLINK -ne 0 ]]; then
	echo "We're DELETING ${#FILES[@]} BACKUP ('*.${BACKUP}') file${b} now:"
elif [[ $RESTORE -ne 0 ]]; then
	echo "We're RESTORING ${#FILES[@]} file${b} now:"
else
	echo "We're inserting ${lines} line${a} in ${#FILES[@]} file${b} now:"
fi; echo; for i in "${FILES[@]}"; do
	echo "    $i"
done; echo

#
errors=0

if [[ $UNLINK -ne 0 ]]; then
	for i in "${FILES[@]}"; do
		echo "\`rm '$i'\`"
		rm "$i" 2>/dev/null
		if [[ $? -ne 0 ]]; then
			let errors=$errors+1
			echo "[ERROR] Unable to remove the backup file '$i'! Ignoring.." >&2
		fi
	done
elif [[ $RESTORE -ne 0 ]]; then
	for i in "${FILES[@]}"; do
		ORIG="${i:: -7}"
		if [[ ! -f "$ORIG" ]]; then
			echo "[WARNING] The original file '$ORIG' for it's backup file does no longer exist (as file)! Ignoring.." >&2
			let errors=$errors+1
		fi
		mv "$i" "$ORIG" 2>/dev/null
		if [[ $? -ne 0 ]]; then
			let errors=$errors+1
			echo "[ERROR] Unable to restore the file '$i' from it's backup! Ignoring.." >&2
		fi
	done
else
	for i in "${FILES[@]}"; do
		if [[ ! -r "$i" ]]; then
			let errors=$errors+1
			echo "[WARNING] Can't read the file '$i'. Ignoring.." >&2
		else
			data="${DATA}"
			while read -r line; do
				data="${data}
	${line}"
			done <"$i"
			eval "cp '$i' '${i}.${BACKUP}'"
			if [[ $? -ne 0 ]]; then
				let errors=$errors+1
				echo "[ERROR] Unable to backup the file '$i'! Leaving it UNTOUCHED!" >&2
				continue
			fi
			echo "$data" >"$i"
			if [[ $? -ne 0 ]]; then
				let errors=$errors+1
				echo "[ERROR] Unable to write to the file '$i' (so it's backup is being removed now)!" >&2
				rm "${i}.${BACKUP}"
			fi
		fi
	done
fi

[[ $errors -gt 0 ]] && echo
echo -n "Finished! "

if [[ $errors -eq 0 ]]; then
	echo -e "\e[1m:-)\e[0m"
else
	s="s"; [[ $errors -eq 1 ]] && s=""
	echo -e "But ${errors} error${s} or warning${s} occured! \e[1m:-(\e[0m"
	exit 255
fi
