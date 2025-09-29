#!/usr/bin/env bash
# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/utilities/
# v0.3.14
#
# JFYI: This is a really old design, so I'm not sure
# whether everything is really "fine" and "correct",
# or most "efficient", etc.. BUT IT WORX for me. ^_^
#
# AND you should know: we're using a symbolic link
# '/opt/node.js/0' by default (to a directory named
# by the real Node.js version). AND it's still up to
# you to create symlinks below '/usr/*' - mostly the
# `bin/node`, etc.. BUT this is only necessary ONE
# TIME: every future update (via this script) will
# *add* the newer version and replace the '0'-link,
# which should be the target of all your links in
# the '/usr' hierarchy! ;-)
#
# New since v0.3.11: the $tmpdir is now also below
# the '/opt/node.js/' directory. The problem was:
# I configured my '/etc/fstab' w/ the 'noexec'
# option for my '/tmp/' (on ram disk).. ;-)
#

#for termux:
#DEPENDS="binutils libc++ openssl c-ares libicu zlib libuv clang make pkg-config python"
#DEPENS="ninja-build"

#
#only used for termux build..
cpu="arm64"
os="android"

#
target="$4"

#tmpdir="/tmp/node.js/"
[[ -z "$target" ]] && target="/opt/node.js/"
originalTarget="$target"
tmpdir="${target}/tmp/"

#
url="https://nodejs.org/dist/"
comp="xz" #gz
dl="wget"

#
flags="-O2 -pipe -ftree-vectorize"
j=$((`nproc 2>/dev/null`-1))
march="native"

#
version="$1"
static="$2"
noFlags="$3"

#
termux=""
args=""

if [[ -d "/data/data/com.termux/" ]]; then
	termux="yes"
else
	termux="no"
fi

if [[ -z "$static" ]]; then
	static="no"
elif [[ "$static" == "y" ]]; then
	static="yes"
elif [[ "$static" == "static" ]]; then
	static="yes"
elif [[ "$static" != "yes" ]]; then
	static="no"
fi

if [[ -z "$noFlags" ]]; then
	noFlags="no"
elif [[ "$noFlags" == "y" ]]; then
	noFlags="yes"
elif [[ "$noFlags" == "yes" ]]; then
	noFlags="yes"
elif [[ "$noFlags" == "n" ]]; then
	noFlags="no"
elif [[ "$noFlags" == "no" ]]; then
	noFlags="no"
else
	noFlags="no"
fi

#
[[ -z "$j" ]] && j=1

termux_args=""
[[ -n "$os" ]] && termux_args="${termux_args} --dest-os='$os'"
[[ -n "$cpu" ]] && termux_args="$termux_args --dest-cpu='$cpu'"

termux_args="${termux_args} --shared-cares --shared-openssl --shared-zlib" #--with-intl=system-icu

#
if [[ -z "$version" ]]; then
	echo " >> Syntax: $(basename "$0") <version> [ <static> [ <no-flags> [ <target> ] ] ]" >&2
	exit 1
elif [[ "$version" == v* ]]; then
	version="${version:1}"

	if [[ -z "$version" ]]; then
		echo " >> Please argue with a VALID version number/string!" >&2
		exit 2
	fi
fi

if [[ -z "$(which $dl 2>/dev/null)" ]]; then
	echo " >> '$dl' can't be found (to download Node.js).." >&2
	exit 3
fi

#
if [[ "$termux" == "yes" ]]; then
	args="${args} ${termux_args}"

	target="/data/data/com.termux/files/${target}/"
	tmpdir="/data/data/com.termux/files/home/${tmpdir}/"

	#
	# this is new (a fix), since v0.3.9:
	#
	[[ ! -e "$HOME/.gyp" ]] && mkdir "$HOME/.gyp/"
	gypinc="$HOME/.gyp/include.gypi"
	[[ ! -e "$gypinc" ]] && touch "$gypinc"

	grep 'android_ndk_path' "$gypinc" >/dev/null 2>&1

	if [[ $? -ne 0 ]]; then
		add='{
	"variables":
	{
		"android_ndk_path": ""
	}
}'
		if [[ `stat -c '%s' "$gypinc"` -eq 0 ]]; then
			echo -e "$add" >"$gypinc"
		else
			echo " >> You need to add the following code to your '$gypinc':" >&2
			echo -e "'$add'" >&2
			echo " >> Wasn't done automatically because this file was not empty." >&2
			exit 127
		fi
	fi
else
	if [[ `id -u` -ne 0 ]]; then
		echo " >> You need to be the 'root' superuser to do this.." >&2
		exit 4
	fi

	flags="$flags -march=$march"
fi

#
if [[ ! -d "$tmpdir" ]]; then
	if [[ -e "$tmpdir" ]]; then
		echo " >> Temporary directory is not a directory." >&2
		exit 16
	else
		mkdir -pv "$tmpdir"
	fi
fi

#
symlink="${target}/0"

if [[ -d "${target}" ]]; then
	target="$(realpath "${target}")/${version}"
elif [[ -e "${target}" ]]; then
	echo " >> Target '$target' already exists, but is not a directory." >&2
	exit 15
fi

if [[ -d "$target" ]]; then
	echo " >> This version seems to be compiled already (--prefix path exists)" >&2
	exit 5
fi

#
if [[ "$static" == "yes" ]]; then
	args="${args} --fully-static"
	target="${target}-static/"
else
	target="${target}/"
fi

args="--prefix='${target}' ${args}"

#
if [[ "$noFlags" == "yes" ]]; then
	unset MAKEFLAGS
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS
else
	[[ -z "$MAKEFLAGS" ]] && export MAKEFLAGS="-j$j"
	[[ -z "$CFLAGS" ]] && export CFLAGS="$flags"
	[[ -z "$CXXFLAGS" ]] && export CXXFLAGS="$flags"
	[[ -z "$CPPFLAGS" ]] && export CPPFLAGS="$flags"
fi

#
file="node-v${version}.tar.${comp}"
url="${url}/v${version}/${file}"

if [[ "$url" != http?://* ]]; then
	echo " >> Invalid URL '$url'!" >&2
	exit 6
fi

if [[ -e "$target" ]]; then
	echo " >> Target directory '$target' already exists!" >&2
	exit 7
fi

#
download()
{
	useWget()
	{
		local wh="$(which "wget" 2>/dev/null)"

		if [[ $? -ne 0 ]]; then
			echo " >> PROBLEM: Couldn't find 'wget' to download.. aborting!" >&2
			exit 8
		fi

		echo " >> Downloading '$file' (`pwd`).."
		echo
		$wh --continue "$url"

		if [[ $? -ne 0 ]]; then
			echo " >> FAILED to download '$url'.." >&2
			exit 9
		else
			echo " >> Sucessfully downloaded '$url'"
		fi
	}

	useCurl()
	{
		local wh="$(which "curl" 2>/dev/null)"

		if [[ $? -ne 0 ]]; then
			echo " >> PROBLEM: Couldn't find 'curl' to download.. aborting!" >&2
			exit 10
		fi

		echo " >> Downloading '$file' (`pwd`).."
		echo
		$wh --continue-at - --output "$file" "$url"

		if [[ $? -ne 0 ]]; then
			echo " >> FAILED to download '$url'.." >&2
			exit 11
		else
			echo " >> Successfully downloaded '$url'"
		fi
	}

	useNetCut()
	{
		echo "(TODO) 'netcut' routine not yet implemented" >&2
		exit 12
	}

	invalidDl()
	{
		echo " >> PROBLEM: Invalid downloader '$dl'! Aborting." >&2
		exit 13
	}

	#if [[ -e "$file" ]]; then
	#	echo " >> File seems to be downloaded already.. old one will be deleted here!" >&2
	#	rm -rfv "$file"
	#fi

	if [[ "$dl" == "wget" ]]; then
		useWget
	elif [[ "$dl" == "curl" ]]; then
		useCurl
	elif [[ "$dl" == "netcut" ]]; then
		useGet
	else
		invalidDl
	fi
}

#
dir="node-v${version}"

untar()
{
	tar -xpf "$file"

	if [[ -d "$dir" ]]; then
		echo " >> Unpacked (\`tar -xpf\`) to './${dir}/'"
		cd "./${dir}/"
	else
		echo " >> FAILED to un-tar (xpf) '$file'" >&2
		exit 14
	fi
}

configure()
{
	#cmd="CC=gcc-11 ./configure ${args}"
	cmd="./configure ${args}"
	echo " >> '$cmd'"
	echo
	eval "$cmd"
}

compile()
{
	echo
	make
}

install()
{
	echo
	make install
}

build()
{
	untar
	configure
	compile
	install
}

createSymlink()
{
	[[ -e "$symlink" ]] && rm "$symlink"
	ln -s "$version" "$symlink"
}

mergeSymlinks()
{
	echo '(TODO: mergeSymlinks())' >&2
}

start()
{
	tmpdir="$(realpath "$tmpdir")"
	target="$(realpath "$target")"
	cd "$tmpdir"
	infos
}

really()
{
	local cont; read -p " >> Do you want to continue [yes/no]? " cont

	case "${cont,,}" in
		y*)
			begin;;
		*)
			echo
			echo ' >> Aborting..' >&2
			exit 7
	esac
}


infos()
{
	printf " >> That's your environment etc."
	echo
	echo
	printf "%16s: %s\n" "Node.js version" "v${version}"
	printf "%16s: %s\n" "Static build" "${static}"
	printf "%16s: %s\n" "Termux build" "${termux}"
	printf "%16s: %s\n" "No flags buid" "${noFlags}"
	if [[ "$termux" == "yes" ]]; then
		[[ -n "$os" ]] && printf "%16s: %s\n" "OS" "$os"
		[[ -n "$cpu" ]] && printf "%16s: %s\n" "CPU" "$cpu"
	fi
	echo
	printf "%16s: '%s'\n" "Temp directory" "$tmpdir"
	printf "%16s: '%s'\n" "Target" "$target"
	printf "%16s: '%s'\n" "Downloader" "$dl"
	echo
	printf "%16s: '%s'\n" "Arguments" "$args"
	echo
	printf "%16s: '%s'\n" "FLAGS" "$CFLAGS"
	printf "%16s: '%s'\n" "MAKEFLAGS" "$MAKEFLAGS"
	echo

	really
	echo
}

begin()
{
	echo

	download
	build
	cleanup
	check
}

cleanup()
{
	cd
	rm -rf "$tmpdir"

	if [[ $? -ne 0 ]]; then
	  echo " >> Unable to remove the '$tmpdir'! Maybe a process is in there?" >&2
	  echo " >> So please remove this directory manually afterwards.." >&2
	fi
}

check()
{
	echo
	if [[ -d "$target" ]]; then
		echo -e " >> SUCCESS (v${version} => '${target}')! \e[1m:-)\e[0m"
		createSymlink
		#mergeSymlinks
		echo " >> You can now \`cd\` to '${originalTarget}' and \`rm -rf\` old version(s) [this is 'v${version}', btw ;-]."
	else
		echo -e " >> FAILED (v${version})! \e[1m:-(\e[0m"
		exit 14
	fi
}

#
start

#

