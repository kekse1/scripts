#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/
# v0.3.2
#

#
# Following steps in this helper script:
#
# (1) Download/Update all RFCs (text/only) into the target directory - they get
#	synced via `rsync` (`$_RFC_HOST`, `$_RFC_SYNC`, maybe `$_RFC_skip_rsync`);
# (2) Put all this `*.txt` files into a single `.txt` output file - SORTED ORDER!
#	The extra files (`rfc-index.txt`, etc.) will be on top of this file. But
#	you can decide to skip 'em => `$_RFC_extra_skip` (maybe `$_RFC_extra_eol`).
#
# This way I can train my own A.I. with "everything" in only a single
# file (my reason to create this `bash` shell script ;-) ...
#
# See also the variables below this comment.
# They can also be set before calling this script, easily in your terminal.
# You can even set `$_RFC_DIR` instead of the only command line argument.
#

#
[[ -z "$_RFC_HOST" ]] && _RFC_HOST="rsync.rfc-editor.org"
[[ -z "$_RFC_SYNC" ]] && _RFC_SYNC="rfcs-text-only"
[[ -z "$_RFC_SUFFIX" ]] && _RFC_SUFFIX=".txt"
# delete older files which are no longer there on the outside!?
[[ -z "$_RFC_delete" ]] && _RFC_delete=0
# `rsync --quiet` mode
[[ -z "$_RFC_quiet" ]] && _RFC_quiet=1
# also list all erroneous files (at the end)?
[[ -z "$_RFC_verbose" ]] && _RFC_verbose=1
# only if you have got an (older) rsync directory which state is o.k. for you.
[[ -z "$_RFC_skip_rsync" ]] && _RFC_skip_rsync=0
# no real need for, but i think it's 'cleaner'..
[[ -z "$_RFC_disallow_working_directory" ]] && _RFC_disallow_working_directory=1
# if you don't want the extra files (`rfc-index.txt, etc.)
[[ -z "$_RFC_extra_skip" ]] && _RFC_extra_skip=0
# eol's in target file after extra files.
[[ -z "$_RFC_extra_eol" ]] && _RFC_extra_eol=20

#
onSigInt()
{
	trap - INT
	echo -e "\n\n\t(SIGINT) ... so we're aborting here!"

	if [[ -n "$_RFC_DIR" && -e "$_RFC_DIR" && $_had_dir -eq 0 ]]; then
		rm -rf "$_RFC_DIR" 2>/dev/null

		if [[ $? -eq 0 ]]; then
			echo -e "\t(removed unfinished rsync directory)"
		else
			echo -e "\t(UNABLE to remove unfinished rsync directory)" >&2
		fi
	fi
	
	if [[ -n "$_RFC_FILE" && -e "$_RFC_FILE" ]]; then
		rm "$_RFC_FILE" 2>/dev/null

		if [[ $? -eq 0 ]]; then
			echo -e "\t(removed the unfinished output file)"
		else
			echo -e "\t(UNABLE to remove unfinished output file)" >&2
		fi
	fi

	echo	
	exit 130
}

trap onSigInt INT

#
#got no effect for this script.. is only used for user output.
#
_SUB=( BCP FYI IEN STD )

#
syntax()
{
	local _string='\n\tSyntax: $0 < target directory >\n\t\t[ --help / -h / -? ]\n\t\t[ --list / -l ]\n'

	if [[ -n $1 && $1 -ne 0 ]]; then
		echo -e "$_string" >&2
	else
		echo -e "$_string"
	fi

	[[ -n "$1" ]] && exit $1
}

listing()
{
	rsync "${_RFC_HOST}::"
}

#
if [[ -z "$_RFC_SUFFIX" ]]; then
	echo -e "ERROR: Invalid \`\$_RFC_SUFFIX\` variable/configuration!" >&2
	exit 2
fi

#
for i in "$@"; do
	if [[ "$i" == "--list" || "$i" == "-l" ]]; then
		listing; exit
	elif [[ "$i" == "--help" || "$i" == "-h" || "$i" == "-?" ]]; then
		syntax 0
	fi
done

#
if [[ $_RFC_skip_rsync -eq 0 ]]; then
	_RSYNC="$(which rsync 2>/dev/null)"

	if [[ $? -ne 0 ]]; then
		echo -e "ERROR: Unable to find \`rsync\` on your host!" >&2
		exit 3
	fi
elif [[ ! -d "$_RFC_DIR" ]]; then
	echo -e "Skipped \`rsync\`, but there's no directory with an older state! :-/" >&2
	exit 4
fi

#
[[ -z "$_RFC_DIR" ]] && _RFC_DIR="$1"

if [[ -z "$_RFC_DIR" ]]; then
	echo -e "Missing target directory parameter." >&2
	syntax 1
fi

_RFC_DIR="$(realpath "$_RFC_DIR" 2>/dev/null)"

if [[ $? -ne 0 ]]; then
	echo -e "Invalid target directory!" >&2
	exit 5
elif [[ $_RFC_disallow_working_directory -ne 0 && "$_RFC_DIR" == "$(realpath ./)" ]]; then
	echo -e "Target directory may not be your current working directory!" >&2
	exit 6
fi

[[ -z "$_RFC_FILE" ]] && _RFC_FILE="$(realpath "${_RFC_DIR}${_RFC_SUFFIX}" 2>/dev/null)"

if [[ $? -ne 0 ]]; then
	echo -e "Invalid target file '${_RFC_FILE}'!" >&2
	exit 7
elif [[ -e "$_RFC_FILE" ]]; then
	echo -e "Target file '${_RFC_FILE}' may not already exist!" >&2
	exit 8
fi

#
echo -e "Directory: $(realpath --relative-to . "$_RFC_DIR")"
echo -e "     File: $(realpath --relative-to . "$_RFC_FILE")"

#
_had_dir=0; if [[ $_RFC_skip_rsync -eq 0 ]]; then
	[[ -d "$_RFC_DIR" ]] && _had_dir=1
	_delete=""; [[ $_RFC_delete -ne 0 ]] && _delete="--delete"
	_quiet=""; [[ $_RFC_quiet -ne 0 ]] && _quiet="--quiet"
	
	_CMD="'$_RSYNC' -avz $_delete $_quiet $_quiet '${_RFC_HOST}::${_RFC_SYNC}' '$_RFC_DIR'"
	echo -e "\`${_CMD}\`\n"
	eval "$_CMD"

	if [[ $? -ne 0 ]]; then
		echo -e "\nERROR: An error occured when trying to \`rsync\`!" >&2
		exit 9
	fi
fi

#
FILES=()
EXTRA=()

while IFS= read -r -d '' file; do
	if [[ "$file" =~ [0-9]+ ]]; then
		FILES+=("$file")
	elif [[ "$(basename "$file")" != "RFCs_for_errata.txt" ]]; then
		EXTRA+=("$file")
	fi
done < <(find "$_RFC_DIR" -iname '*.txt' -type f -print0)

files=${#FILES[@]}
extra=${#EXTRA[@]}
total=$((files+extra)); [[ $_RFC_extra_skip -ne 0 ]] && ((total-=extra))

if [[ $files -eq 0 ]]; then
	echo -e "No valid RFC files found in directory '${_RFC_DIR}'! :-/" >&2
	exit 10
fi

echo; (IFS=/; echo -e "Found $files RFCs in total (inluding all ${_SUB[*]}).")
if [[ $extra -gt 0 ]]; then
	if [[ $_RFC_extra_skip -eq 0 ]]; then
		echo -e "There are also $extra extra files (like `rfc-index.txt`, ...)."
	else
		echo -e "Due to your configuration we skip $extra extra files!"
	fi
fi

#
_errors=()

#
if [[ $extra -gt 0 && $_RFC_extra_skip -eq 0 ]]; then
	mapfile -t EXTRAS < <(printf "%s\n" "${EXTRA[@]}" | sort -V); unset EXTRA

	echo -e "\nExtra files ($extra):\n"
	for i in "${EXTRAS[@]}"; do
		echo -en " >> $(basename "$i") ... "
		cat "$i" >>"$_RFC_FILE"
		if [[ $? -eq 0 ]]; then
			echo "OK"
		else
			echo "ERROR"
			_errors+=("$i")
		fi
	done

	[[ -n $_RFC_extra_eol && $_RFC_extra_eol -gt 0 ]] && \
		for i in `seq 1 $_RFC_extra_eol`; do
			echo >>"$_RFC_FILE"; done
fi

#
if false; then
mapfile -t SORTED < <(printf "%s\n" "${FILES[@]}" | sort -V); unset FILES

echo -e "\nRegular files ($((files-extra))):\n"
for i in "${SORTED[@]}"; do
	echo -en " >> $(basename "$i") ... "
	cat "$i" >>"$_RFC_FILE"
	if [[ $? -eq 0 ]]; then
		echo "OK"
	else
		echo "ERROR"
		_errors+=("$i")
	fi
done; echo;
fi

#
_error=${#_errors}
_done=$((files-_error))
echo

if [[ $_done -gt 0 ]]; then
	echo -e "Successfully wrote $_done (of $total in total) RFCs into your '${_RFC_FILE}'! :-)"

	if [[ $_error -gt 0 ]]; then
		echo -e "But I was unable to handle $_error RFCs. :-/" >&2
		
		if [[ $_RFC_verbose -ne 0 ]]; then
			echo; for i in "${_errors[@]}"; do
				echo -e " >> $i"
			done; echo;
		fi
		
		exit 127
	fi
else
	echo -e "_Totally_ UNABLE to read/write $total RFCs! :-(" >&2
	exit 128
fi

