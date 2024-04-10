#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v2.1.1
#
# Copy this script to '/etc/profile.d/prompt.sh'.
# 
# BUT MAYBE other scripts or so override this `$PS1`
# configuration ('/etc/profile', '/etc/bash.bashrc',
# maybe '~/.bashrc' or '~/.profile') .. in this case
# try to find and remove 'em, using `grep`. ok?
#

#
_TERMUX=0
_MULTI_LINE=1
_SLASHES=4
_REST_STRING="..."
_WITH_FILES=1
_WITH_HOSTNAME=1
_WITH_USERNAME=1
_WITH_LOAD_AVG=1
_WITH_DATE=1
_DATE_FORMAT_ONE='%H:%M:%S'
_DATE_FORMAT_TWO='%j'

#
if [[ $_TERMUX -ne 0 ]]; then
	_SLASHES=3
	_WITH_DATE=0
	_WITH_HOSTNAME=0
	_WITH_USERNAME=0
	_WITH_LOAD_AVG=0
	#_WITH_FILES=0
fi

#
ps1Prompt()
{
	#
	ret=$?

	#
	startFG()
	{
		PS1="$PS1"'\[\033[38;2;'"$1;$2;$3"'m\]'
	}

	startBG()
	{
		PS1="$PS1"'\[\033[48;2;'"$1;$2;$3"'m\]'
	}

	startBold()
	{
		PS1="$PS1"'\[\033[1m\]'
	}

	ansiReset()
	{
		PS1="$PS1"'\[\033[m\]'
	}

	write()
	{
		PS1="$PS1$*"
	}

	getBase()
	{
		_depth=$1
		shift
		_dir="$*"
		res=""
		slashCount=0

		if [[ ${_dir} == "/" ]]; then
			write ' / '
			return
		fi

		while [[ "${_dir: -1}" = "/" ]]; do
			_dir="${_dir::-1}"
		done

		homeLen=${#HOME}
		
		if [[ "$_dir" == "$HOME" ]]; then
			_dir="~"
		elif [[ "${_dir:0:$(($homeLen + 1))}" = "$HOME/" ]]; then
			_dir="~${_dir:$homeLen}"
		fi

		for (( i=${#_dir}-1; i >= 0; i-- )); do
			if [[ ${_dir:$i:1} == "/" ]]; then
				let slashCount=$slashCount+1
				res="/${res}"

				if [[ $slashCount -eq $_depth ]]; then
					inHome=0
					upper=""

					for (( j=$i-1; j >= 0; j--)); do
						if [[ "${_dir:$j:1}" != "/" ]]; then
							upper="${_dir:$j:1}${upper}"
						fi
						
						if [[ "$upper" == "~" ]]; then
							inHome=1
							break
						fi
					done

					if [[ $inHome -ne 0 ]]; then
						res="~${res}"
					elif [[ $i -gt 0 ]]; then
						res="${_REST_STRING}${res}"
					fi
					break
				fi
			else
				res="${_dir:$i:1}${res}"
			fi
		done

		write " $res "
	}

	#
	PS1=""

	#
	startFG 180 115 25
	write ' » '
	ansiReset
	user_host=0

	#
	if [[ $_WITH_USERNAME -ne 0 ]]; then
		if [[ `id -u` -eq 0 ]]; then
			startBG 175 65 245
		elif [[ `id -g` -eq 0 ]]; then
			startFG 175 65 245
		else
			startFG 225 245 70
		fi

		startBold
		write "`id -nu`"
		ansiReset
		user_host=1
	fi

	if [[ $_WITH_HOSTNAME -ne 0 ]]; then
		write '@'
		startFG 245 195 65
		#write "$HOSTNAME"
		write "`hostname`"
		ansiReset
		user_host=1
	fi

	[[ $user_host -ne 0 ]] && write ' '
	
	#
	if [[ $_WITH_DATE -ne 0 && -n "$_DATE_FORMAT_ONE" ]]; then
		startFG 110 200 255
		write "`date +"$_DATE_FORMAT_ONE"` "
		if [[ -n "$_DATE_FORMAT_TWO" ]]; then
			startFG 210 140 30
			write "`date +"$_DATE_FORMAT_TWO"` "
		fi
		ansiReset
	fi
	
	#
	if [[ $_WITH_LOAD_AVG -ne 0 && -r /proc/loadavg ]]; then
		read one five fifteen rest </proc/loadavg
		startFG 180 250 0
		write "$one $five $fifteen "
		ansiReset
	fi

	#
	if [[ $_WITH_FILES -ne 0 ]]; then
		#
		startFG 190 60 250
		write "`find -maxdepth 1 -type f | wc -l`"
		startFG 200 220 20
		write '/'
		startFG 250 60 180
		write "$((`find -maxdepth 1 -type d | wc -l`-1)) "
		ansiReset
	fi
	
	#
	[[ $_MULTI_LINE -ne 0 ]] && write "\n "
	
	#
	if [[ $ret -eq 0 ]]; then
		startBG 170 230 70
		startFG 0 0 0
		write ' ✔ '
	else
		startBG 210 45 25
		startFG 255 255 255
		write ' ✘ '
	fi

	ansiReset

	#
	jc=`jobs -p | wc -l`
	if [[ $jc -gt 0 ]]; then
		write ' '
		startBG 140 30 140
		startFG 255 255 255
		write " $jc "
		ansiReset
	fi
	
	#
	write ' '
	startBG 95 160 205
	startFG 0 0 0
	getBase $_SLASHES "`pwd`"
	ansiReset
	write ' '

	#
	export PS1
}

export PROMPT_COMMAND=ps1Prompt

