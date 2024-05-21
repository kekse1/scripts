#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/norbert/
# v0.3.0
#
# I do initialize a sub part of my bigger project with
# the help of this script.
#
# See the $COPY file list. And end each item without
# slash to only initialize it empty (even though dirs
# contain entries in your original project). Symbolic
# Links stay exactly the same (so using `readlink`).
#

#
# if no '/' after a directory, it'll be created empty!
# and always preserve symlinks, do NOT resolve/follow 'em!
#
COPY='ADMIN.txt
config/netz.json
COPYRIGHT.txt
docs/ADMIN.txt
docs/COPYRIGHT.txt
docs/URL.txt
docs/VERSION.txt
js/netz/
js/package.json
js/shared/
logs
netz.sh
NORBERT.txt
package.json
root/htdocs
root/netz/network/server/web/default/
root/netz/network/server/net
run
sh/copy-netz.sh
sh/netz.sh
URL.txt
usr/bin/netz.sh
usr/etc/norbert
usr/home/norbert
usr/log/norbert
usr/run
usr/var/log/norbert
usr/var/run
VERSION.txt'

#
TARGET="$1"

if [[ $# -eq 0 ]]; then
	echo "Please define a target path for the extracted \`Netz\` project!" >&2
	exit 1
else
	TARGET="$(realpath "$TARGET")"
fi

if [[ -e "$TARGET" ]]; then
	if [[ -d "$TARGET" ]]; then
		read -p "Are you sure to copy our tree to '$TARGET' [yes/no]!? " cont
		cont="${cont::1}"
		cont="${cont,,}"
		case "$cont" in
			y)
				;;
			*)
				echo "Aborted!" >&2
				exit 2
				;;
		esac
	else
		echo "Target path exists, but ain't a directory! Aborting here.." >&2
		exit 3
	fi
else
	read -p "Do you want to create the target '$TARGET' [yes/no]? " cont
	cont="${cont::1}"
	cont="${cont,,}"
	case "$cont" in
		y)
			;;
		*)
			echo "Aborted!" >&2
			exit 4
			;;
	esac
	mkdir -p "$TARGET"
	if [[ $? -ne 0 ]]; then
		echo "Unable to create target directory '$TARGET'!" >&2
		exit 5
	fi
fi

#
REAL="$(realpath "$0")"
DIR="$(dirname "$REAL")"
ALL="$(realpath "${DIR}/../")"

if [[ "$ALL" == "$TARGET" ]]; then
	echo "You can't copy the tree to itself!" >&2
	exit 6
fi

IFS=$'\n' COPY=( $COPY )

for i in "${COPY[@]}"; do
	dn="$(dirname "$i")"
	[[ "$dn" == "." ]] && dn=""
	td="${TARGET}/$dn"
	p="${ALL}/$i"
	e=1
	d=0
	l=0
	if [[ -L "$p" ]]; then
		l=1
	elif [[ -d "$p" ]]; then
		d=1
		[[ "${i: -1}" == "/" ]] && e=0
	else
		d=0
	fi
	[[ "${i: -1}" == "/" ]] && i="${i:: -1}"
	target="${TARGET}/$i"
	echo "$p { link: $l, dir: $d, empty: $e }"
	CMD1=""
	CMD2="rm -f"
	[[ $d -ne 0 ]] && CMD2="${CMD2}r"
	if [[ $e -ne 0 && $d -ne 0 ]]; then
		CMD1="mkdir '$target'"
	elif [[ $l -ne 0 ]]; then
		CMD1="ln -s '$(readlink "$p")' '$target'"
	else
		CMD1="cp"
		[[ $e -eq 0 ]] && CMD1="${CMD1} -r"
		CMD1="${CMD1} '$p' '$target'"
	fi
	CMD2="${CMD2} '$target' 2>/dev/null"
	CMD1="${CMD1} 2>/dev/null"
	mkdir -p "$td" 2>/dev/null
	eval "$CMD2"
	eval "$CMD1"
done

#
_keep_files()
{
	_created=0
	_existed=0
	_erroneous=0

	traverse()
	{
		cd "$1"

		if [[ $? -ne 0 ]]; then
			let _erroneous=$_erroneous+1
			return 1
		fi

		if [[ -e "$1/.keep" ]]; then
			let _existed=$_existed+1
		else
			touch "$1/.keep"

			if [[ $? -eq 0 ]]; then
				let _created=$_created+1
			else
				let _erroneous=$_erroneous+1
			fi
		fi

		for i in *; do
			p="$1/$i"

			if [[ -L "$p" ]]; then
				continue
			elif [[ -d "$p" ]]; then
				traverse "$p"
			fi
		done
	}

	_orig="`pwd`"
	traverse "$1"
	cd "$_orig"
	[[ $_erroneous -ne 0 ]] && return 1
	return 0
}

#
_keep_files "$TARGET"
[[ $? -ne 0 ]] && echo "Couldn't create all \`.keep\` files in target directories.. :-/" >&2

#
echo "Created a deep copy of ${#COPY[@]} items (recursions *not* counted). :-)"
