#!/usr/bin/env bash

#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.3
#
# Downloads the *latest* wiki dumps. See the '$url' vector.
# After downloading, they'll be `bunzip2`d. Implemented
# with some checks to be absolutely sure, and also creates
# backups, etc. .. jfyi.
#
# Syntax: $0 [ <target directory> ]
#
# So the only parameter is optional - if not set, it'll
# use the $PWD (current working directory). This script
# will also check for the existence of maybe previously
# downloaded files, so it'll create a backup. Therefore
# we create '${TARGET}/BACKUP/', or 'BACKUP #1' and so on
# if it already existed.
#
# Really nothing big, but I found it useful due to the
# training of my `Norbert` <https://norbert.com.es/>. ;-)
#
# Depends on the `wget` and `bunzip2` utility.
# Their existence on your system is being checked before.
#
# The '$SIMULATE' is just another debug function I'm massively
# using when developing scripts. You should set it to (0).
#

#
url=(
	"https://dumps.wikimedia.org/dewiki/latest/dewiki-latest-pages-articles-multistream.xml.bz2"
	"https://dumps.wikimedia.org/dewikibooks/latest/dewikibooks-latest-pages-articles-multistream.xml.bz2"
	"https://dumps.wikimedia.org/dewikisource/latest/dewikisource-latest-pages-articles-multistream.xml.bz2"
	"https://dumps.wikimedia.org/dewiktionary/latest/dewiktionary-latest-pages-articles-multistream.xml.bz2"
	"https://dumps.wikimedia.org/dewikiquote/latest/dewikiquote-latest-pages-articles-multistream.xml.bz2"
)

SIMULATE=0

#
real="$(realpath "$0")"
dir="$(dirname "$real")"

#
TARGET="$1"; [[ -z "$TARGET" ]] && TARGET="`pwd`"
TARGET="$(realpath "$TARGET" 2>/dev/null)"

if [[ $? -ne 0 ]]; then
	echo "Invalid target directory!" >&2
	exit 1
fi

#
WGET="wget"
WGET="$(which "$WGET" 2>/dev/null)"

if [[ $? -ne 0 ]]; then
	echo "[ERROR] Unable to locate your \`wget\` utility. Maybe not installed?" >&2
	exit 2
fi

BUNZIP2="bunzip2"
BUNZIP2="$(which "$BUNZIP2" 2>/dev/null)"

if [[ $? -ne 0 ]]; then
	echo "[ERROR] Unable to locate your \`bunzip2\` utility. Maybe not installed?" >&2
	exit 3
fi

#
cd "$TARGET"
echo -e "So we are going to download these ${#url[@]} files via \`wget\`:\n"
_found_old=0

BACKUP_DIRECTORY="BACKUP"
backup_directory="$BACKUP_DIRECTORY"
tries=0; while [[ -e "$backup_directory" ]]; do
	let tries=$tries+1
	backup_directory="${BACKUP_DIRECTORY} #${tries}"
done; mkdir "$backup_directory"

for i in "${url[@]}"; do
	echo "  >> $i"
	if [[ "${i: -4}" != ".bz2" ]]; then
		echo "[WARN] Maybe invalid wiki-dump URL? It's extension is not '.bz2'! Aborting.." >&2
		exit 4
	fi
	_base="$(basename "$i")"
	_bunzip="${_base:: -4}"
	
	if [[ -e "$_base" ]]; then
		let _found_old=$_found_old+1

		mv "$_base" "$backup_directory"
		
		if [[ $? -ne 0 ]]; then
			echo -e "[ERROR] Unable to backup the file '$_base'!" >&2
			echo "Aborting..." >&2
			exit 5
		else
			echo "[INFO] Found previously downloaded '$_base', so we created a backup."
		fi
	fi
	
	if [[ -e "$_bunzip" ]]; then
		let _found_old=$_found_old+1
		
		mv "$_bunzip" "$backup_directory"
		
		if [[ $? -ne 0 ]]; then
			echo -e "[ERROR] Unable to backup the file '$_bunzip'!" >&2
			echo "Aborting..." >&2
			exit 6
		else
			echo "[INFO] Found previously extracted '$_bunzip', so we created a backup."
		fi
	fi
done; echo

if [[ $_found_old -eq 0 ]]; then
	rmdir "$backup_directory"
else
	s="s"; [[ $_found_old -eq 1 ]] && s=""
	echo -e "You'll find $_found_old backup$s in the directory '$backup_directory' (in your target directory):"
	echo -e "\t${TARGET}/${backup_directory}/\n"
fi

#
for (( i=0; i<${#url[@]}; ++i )); do
	_url="${url[$i]}"
	_base="$(basename "$_url")"
	_bunzip="${_base:: -4}"

	if [[ $SIMULATE -eq 0 ]]; then
		$WGET -c "$_url"
	else
		true
	fi

	if [[ $? -ne 0 ]]; then
		echo "[ERROR] Couldn't download '$_base'!" >&2
		echo "Aborting..."
		exit 5
	fi

	if [[ $SIMULATE -eq 0 ]]; then
		$BUNZIP2 <"$_base" >"$_bunzip"
	else
		true
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "\nSuccessfully downloaded and extracted the '$_base'!\n"
		rm "$_base"

		if [[ $? -ne 0 ]]; then
			echo "[ERROR] Unable to remove download '$_base'!?" >&2
			echo "Aborting..." >&2
			exit 6
		fi

		url[$i]="$_bunzip"
	else
		echo -e "\n[ERROR] Unable to \`bunzip2\` the '$_base' (but successfully downloaded it)." >&2
		echo "Aborting..."
		exit 7
	fi
done

echo
echo -e "Successfully downloaded and extracted ${#url[@]} files:\n"

for i in "${url[@]}"; do
	echo -ne "\t >> "
	if [[ $SIMULATE -eq 0 ]]; then
		ls -ahl "$i"
	else
		echo "$i (*not* downloaded, only simulated)"
	fi
done; echo

