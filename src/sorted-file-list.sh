#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.1
#

# set to zero(0) to enable this whole tool! .. ^_^
_DRY_RUN=1

#
[[ $_DRY_RUN -ne 0 ]] && echo -e "FYI: Set \`\$_DRY_RUN\` (on top of this script) to zero(0) to really use this tool!\n" >&2

#
syntax()
{
	echo -e "This script will copy all matching files into a (newly created) target directory," >&2
	echo -e "each with a numerical, counted prefix to keep the order of files, which will be" >&2
	echo -e "enumerated by their file size (ascending by default).\n" >&2
	echo -e "\tSyntax: \$0 < target directory > [ < glob > [ < padding > [ < start > ] ] ]\n" >&2
	echo -e "Please run this command in the directory where the files you need are located." >&2
	echo -e "You first *need* to argue with a target directory path which doesn't already exist." >&2
	echo -e "\n\tPossible parameters:\n" >&2
	echo -e "The 'target directory' is the place to copy the file listing into." >&2
	echo -e "The 'glob' is '*' by default. You can change it; BUT PUT IT INTO QUOTES, LIKE: '*.log'!" >&2
	echo -e "The 'padding' can be empty, to dynamically choose how many zeros will pad the new count prefix." >&2
	echo -e "The 'start' changes from where the counting will start. Empty value will start with (1) by default." >&2
	echo -e "\nTo bypass a parameter and define a subsequent one, just use an empty string like this: ''." >&2
	echo >&2
}

errorCase()
{
	local _print=$1
	local _force=$2

	rmdir "$_TARGET"
	local _res=$?
	
	if [[ $_res -eq 0 ]]; then
		[[ $_print -ne 0 ]] && echo -e "The error caused me to delete the target directory." >&2
		return 0
	fi

	if [[ $_print -ne 0 || $_force -ne 0 ]]; then
		echo -e "Sorry, I tried to delete the target directory because of the error," >&2
		echo -e "but it didn't work (error code = ${_res}). Please do it manually." >&2
	fi
	
	return 1
}

confirm()
{
	[[ -n "$1" ]] && echo -ne "$1 [Yes/No]? "
	local confirm; read confirm;
	confirm="${confirm::1}"; confirm="${confirm,,}"
	[[ "$confirm" != "y" ]] && return 1
	return 0
}

#
if [[ $# -eq 0 ]]; then
	syntax
	exit 1
fi

args=()

for i in "$@"; do
	case "$i" in
		"--help"|"-h"|"-?")
			syntax
			exit
			;;
		*)
			args+=("$i")
			;;
	esac
done

#
_TARGET="${args[0]}"
_GLOB="${args[1]:-*}"
_PADDING="${args[2]}"
_START=${args[3]:-1}

#
if [[ "$_GLOB" != *"*"* ]]; then
	echo -e "Your GLOB doesn't contain an asterisk '*'." >&2
	echo -e "So I think, you didn't put your glob parameter into quotes (like: '*.log')!?" >&2
	exit 2
else
	echo -e "Using file glob: \`${_GLOB}\`."
fi

#
if [[ -z "$_TARGET" ]]; then
	syntax
	exit 3
else
	_TARGET="$(realpath -m "$_TARGET")"
fi
		
#
if [[ -e "$_TARGET" ]]; then
	echo -e "\nERROR: Target directory may not already exist: \`${_TARGET}\`" >&2
	echo -e "We need a 'clean environment' for the file listing." >&2
	exit 4
else
	mkdir -p "$_TARGET" >/dev/null 2>&1
	
	if [[ $? -ne 0 ]]; then
		echo -e "\nYour target directory couldn't be created: \`${_TARGET}\`" >&2
		exit 5
	fi
fi

#
mapfile -t -d '' files < <(find -mindepth 1 -maxdepth 1 -not -name '.*' -name "$_GLOB" -type f -printf "%s %f\0" | sort -zn)
_count=${#files[@]}

if [[ $_count -eq 0 ]]; then
	echo "No matching files found!" >&2
	errorCase 0
	exit 6
fi

#
_maxLen=0; for file in "${files[@]}"; do
	_len=${#file}
	[[ $_len -gt $_maxLen ]] && _maxLen=$_len
done; ((_maxLen+=2))

#
if [[ -z "$_PADDING" ]]; then
	_PADDING=${#_count}
	echo "According to your file count we use a padding size of ${_PADDING} now."
elif [[ $_PADDING -lt ${#_count} ]]; then
	echo "Your own padding size ${_PADDING} is too low for the real file count!" >&2
	errorCase 1
	exit 7
else
	echo "Using fixed padding size ${_PADDING}."
fi

echo -e "And I'm going to start counting from ${_START} (up to $(($_START+$_count-1)))."

#
_errors=0; echo; i=$_START

for entry in "${files[@]}"; do
	_name="${entry#* }"
	_prefix=$(printf "%0${_PADDING}d" "$i")
	_target="${_prefix}. ${_name}"

	printf "%-${_maxLen}s \t " "$_target"
	#echo -e "\t${_target}"

	if [[ $_DRY_RUN -eq 0 ]]; then
		cmd="cp '$_name' '${_TARGET}/${_target}'"
		eval "$cmd"
		
		if [[ $? -eq 0 ]]; then
			echo "ok"
		else
			((++_errors))
			echo "failed (${_errors} now)"
		fi
	else
		echo "test"
	fi
	
	((++i))
done; echo

_dryTest()
{
	if [[ $_DRY_RUN -ne 0 ]]; then
		echo -e "\nRemember: this was a \`\$_DRY_RUN\` only!"
		rmdir "$_TARGET" || echo -e "FAILED to remove the target directory afterwards!"
	fi
}

if [[ $_errors -eq 0 ]]; then
	echo -e "Finished to copy ${_count} files into \`$(realpath --relative-to . "${_TARGET}")\`! :-)"
	echo -e "\t${_TARGET}"
	_dryTest
elif [[ $_errors -eq $_count ]]; then
	echo -en "SORRY: not a single file could be copied, " >&2
	echo -e "everything went wrong! :-(" >&2
	errorCase 1
	exit 8
else
	_success=$(($_count-$_errors))
	echo -en "Sorry: ${_success} files could be copied, "
	echo -e "but ${_errors} files couldn't." >&2
	echo -e "\t${_TARGET}"
	_dryTest
	exit 9
fi
