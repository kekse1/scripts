#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v1.3.3
#

# for the `line()`:
#[[ -z "$LINE" ]] && export LINE=",.-'\`'-.,"
#[[ -z "$LINE_COLOR" ]] && export LINE_COLOR="auto"
export LINE=",.-'\`'-.,"
#export LINE_COLOR="auto"
export LINE_COLOR="255 255 0"

# for the `progress()`:
PROGRESS_DONE=( 230 200 60 )
PROGRESS_TODO=( 30 70 130 )
PROGRESS_OB="("
PROGRESS_CB=")"

#
repeat()
{
	local count=$1; shift
	local result=''
	[[ $count -le 0 ]] && return
	local i; for (( i=0; i<$count; ++i )); do
		result="${result}${*}"
	done
	echo "$result"
}

progress()
{
	progresss "$@"
	echo
}

progresss()
{
	local current="$1"
	local total="$2"; [[ -z "$total" || $total -le 0 ]] && total=100
	local width="$3"
	local prec="$4"
	local space="$5"; [[ -z "$space" ]] && space=0

	if [[ -z "$prec" ]]; then
		prec=0
	elif [[ $prec -lt 0 ]]; then
		prec=-1
	elif [[ $prec -gt 6 ]]; then
		prec=6
	fi
	
	if [[ -z "$width" ]]; then
		width=`width`
	elif [[ "${width: -1}" == "%" ]]; then
		width=$((`width`*${width::-1}/100))
	elif [[ $width -eq 0 ]]; then
		width=`width`
	elif [[ $width -lt 0 ]]; then
		width=$((`width`+${width}))
	fi
	
	[[ $width -le 0 ]] && width=${width:1}
	width=$(mod $width $((`width`+1)))
	[[ $space -gt 0 ]] && width=$((${width}-${space}*2))

	if [[ $current -lt 0 ]]; then
		current=0
	elif [[ $current -gt $total ]]; then
		current=$total
	fi

	local factor="`div $current $total`"

	local text=""; local len; if [[ $prec -ge 0 ]]; then
		len=$((${prec}+4))
		text="$(mul $factor 100)"
		text="$(int "$text" $prec)"
		text="$(printf "%${len}s" "$text")"
	fi

	width=$((${width}-${#text}-4))
	local done="$(int `mul $factor $width`)"
	local todo="$(int `sub $width $done`)"
	done="`repeat $done $(bg ${PROGRESS_DONE[@]} ' ')`"
	todo="`repeat $todo $(bg ${PROGRESS_TODO[@]} ' ')`"

	done="`fg "${PROGRESS_DONE[@]}"``bold "${PROGRESS_OB}"`${done}"
	todo="`fg "${PROGRESS_TODO[@]}"`${todo}`fg "${PROGRESS_DONE[@]}"``bold "${PROGRESS_CB}"`"

	if [[ -n "$text" ]]; then
		text="`bold``info`${text}`error`%`none`"
		done="${text} ${done}"
	fi

	if [[ $space -gt 0 ]]; then
		done="`repeat $space ' '`${done}"
		todo="${todo}`repeat $space ' '`"
	fi

	local result="${done}${todo}`none`"
	echo -ne "\r${result}"
}

int()
{
	local value="$1"; local scale="$2"
	[[ -z "$scale" ]] && scale=0
	echo "scale=${scale}; (${value}/1)" | bc
}

add()
{
	echo "$(awk "BEGIN {print ($1)+($2)}")"
}

sub()
{
	echo "$(awk "BEGIN {print ($1)-($2)}")"
}

mul()
{
	echo "$(awk "BEGIN {print ($1)*($2)}")"
}

div()
{
	echo "$(awk "BEGIN {print ($1)/($2)}")"
}

mod()
{
	echo "$(awk "BEGIN {print ($1)%($2)}")"
}

#
line()
{
	local _line="$1"; [[ -z "$_line" ]] && _line="$LINE"; [[ -z "$_line" ]] && _line=",.-'\`'-.,"
	local _string="$2"
	local _start="$3"; [[ -z "$_start" ]] && _start=6
	local _space="$4"; [[ -z "$_space" ]] && _space=" "
	_string="${_space}${_string}${_space}"
	local w=`width`; if [[ $w -eq 0 ]]; then echo; return; fi
	local lineColor="$LINE_COLOR"; [[ -n "$lineColor" && "$lineColor" != "auto" ]] && IFS=' ' lineColor=( $lineColor )
	[[ $lineColor != "auto" ]] && fg "${lineColor[@]}"
	local i; local char; local mod; for (( i=0; i<$w; ++i )); do
		if [[ -n "$_string" && $i -ge $_start ]]; then
			char="${_string::1}"
			_string="${_string:1}"
			none
		else
			mod=$(($i%${#_line}));
			if [[ $lineColor == "auto" ]]; then
				fg $(($RANDOM%256)) $(($RANDOM%256)) $(($RANDOM%256))
			else
				fg ${LINE_COLOR[@]}
			fi
			char="${_line:${mod}:1}"
		fi
		echo -n "$char"
	done; echo -e "`none`"
}

width()
{
	if [[ -n "$COLS" ]]; then
		echo $COLS
	elif [[ -n "$COLUMNS" ]]; then
		echo $COLUMNS
	else
		tput cols 2>/dev/null

		if [[ $? -ne 0 ]]; then
		       echo 0
		       return 1
		fi
	fi
}

height()
{
	if [[ -n "$LINES" ]]; then
		echo $LINES
	else
		tput lines 2>/dev/null

		if [[ $? -ne 0 ]]; then
		       echo 0
		       return 1
		fi
	fi
}

#
none()
{
	echo -en "\e[0m"
}

#
fg()
{
	echo -en "\e[38;2;$1;$2;$3m"
	[[ -n "$4" ]] && echo -en "$4\e[39m"
}

bg()
{
	echo -en "\e[48;2;$1;$2;$3m"
	[[ -n "$4" ]] && echo -en "$4\e[49m"
}

info()
{
	fg 173 234 68 "$*"
}

warn()
{
	fg 232 226 37 "$*"
}

error()
{
	fg 252 131 38 "$*"
}

debug()
{
	fg 150 180 200 "$*"
}

bold()
{
	echo -en "\e[1m"
	[[ -n "$*" ]] && echo -en "$*\e[22m"
}

underline()
{
	echo -en "\e[4m"
	[[ -n "$*" ]] && echo -en "$*\e[24m"
}

italic()
{
	echo -en "\e[3m"
	[[ -n "$*" ]] && echo -en "$*\e[23m"
}

faint()
{
	echo -en "\e[2m"
	[[ -n "$*" ]] && echo -en "$*\e[22m"
}

slow()
{
	echo -en "\e[5m"
	[[ -n "$*" ]] && echo -en "$*\e[25m"
}

fast()
{
	echo -en "\e[6m"
	[[ -n "$*" ]] && echo -en "$*\e[26m"
}

inverse()
{
	echo -en "\e[7m"
	[[ -n "$*" ]] && echo -en "$*\e[27m"
}

hidden()
{
	echo -en "\e[8m"
	[[ -n "$*" ]] && echo -en "$*\e[28m"
}

strike()
{
	echo -en "\e[9m"
	[[ -n "$*" ]] && echo -en "$*\e[29m"
}

#
clearLine()
{
	echo -en "\e[2K"
}

hideCursor()
{
	echo -en '\e[?25l'
}

showCursor()
{
	echo -en '\e[?25h'
}

#
SOURCE()
{
	local _str="Unable to \`source\`"

	if [[ -n "$1" ]]; then
		_str="${_str} the file `warn "$1"`"
	else
		_str="${_str} a required file"
	fi

	ERROR "$_str"

	[[ -n "$2" ]] && exit $2
	exit 123
}

ERROR()
{
	echo -en "  `faint`[`none``error``inverse`ERROR`none``faint`]`none`" >&2
	[[ -n "$*" ]] && echo -e " `error`${*}`none`" >&2
}

WARN()
{
	echo -en "`faint`[`none``warn``inverse`WARNING`none``faint`]`none`" >&2
	[[ -n "$*" ]] && echo -e " `warn`${*}`none`" >&2
}

DEBUG()
{
	echo -en "  `faint`[`none``debug``inverse`DEBUG`none``faint`]`none`" >&2
	[[ -n "$*" ]] && echo -e " `debug`${*}`none`" >&2
}

INFO()
{
	echo -en "   `faint`[`none``info``inverse`INFO`none``faint`]`none`"
	[[ -n "$*" ]] && echo -e " `info`${*}`none`"
}

#
