#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.4.4
#
# Tiny helper (copy it to '/etc/profile.d/fresh.sh'),
# since it is *not* executable (but `source` or `.`).
#
# You should see what the `fresh` function does.
#
# The `keep` will create new (empty) '.keep' files if
# not already existing; it'll traverse recursively
# through all directories below your `pwd` (and it'll
# ignore all hidden (dot) directories (like '.git')!
#

_GIT_DATE_FORMAT='%s'
_GIT_DATE_FORMAT_EXT='%s%N'
_GIT_DATE_SYMBOL='+'

fresh()
{
	_dir="`git rev-parse --git-dir 2>/dev/null`"

	if [[ $? -ne 0 ]]; then
		echo " >> Not inside a git repository!" >&2
		return 1
	else
		_dir="$(realpath "$_dir")"
		_dir="${_dir::-5}"
	fi

	_add=0
	[[ $# -gt 0 ]] && _add=1
	
	_orig="`pwd`"
	cd "$_dir"

	_txt=

	if [[ $_add -eq 0 ]]; then
		echo -e " >> Only fetching latest repository state."
		echo -e " >> To also upload your changes, argue with a commit message (\`$_GIT_DATE_SYMBOL\` for a \`date\`)."
	else
		if [[ "$*" == "$_GIT_DATE_SYMBOL" ]]; then
			_txt="`date +"$_GIT_DATE_FORMAT_EXT"`"
		else
			_txt="`date +"$_GIT_DATE_FORMAT"`"
			_txt="[$_txt] $*"
		fi

		echo -e " >> Repository path:\n    \e[1m${_dir}\e[0m"
		echo -e " >> Applying commit:\n    \e[1m${_txt}\e[0m\n"
	fi

	git pull

	if [[ $_add -ne 0 ]]; then
		git add --all
		git commit -m "$_txt"
		git push
	fi

	cd "$_orig"
}

keep()
{
	_created=0
	_existed=0
	_erroneous=0
	_depth=0

	traverse()
	{
		cd "$1"

		if [[ $? -eq 0 ]]; then
			[[ $2 -gt $_depth ]] && _depth=$2
		else
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
				traverse "$p" $(($2+1))
			fi
		done
	}

	_orig="`pwd`"
	traverse "$_orig" 1

	if [[ $_created -gt 0 ]]; then
		echo -e " >> Created \e[1m${_created}\e[0m \e[4m.keep\e[0m files."
	else
		echo -e " >> \e[1mNO\e[0m \e[4m.keep\e[0m files created."
	fi

	[[ $_existed -gt 0 ]] && echo -e " >> \e[1m${_existed}\e[0m files already existed."
	[[ $_erroneous -ne 0 ]] && echo -e " >> FAILED to create \e[1m${_erroneous}\e[0m files!" >&2
	[[ $_depth -gt 1 ]] && echo -e " >> Traversed recursively up to a maximum depth of \e[1m${_depth}\e[0m."

	cd "$_orig"
	
	[[ $_erroneous -ne 0 ]] && return 1
	return 0
}

