# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.6
#
# Copy to '/etc/profile.d/` to automatically include
# the following functions .. read the source 4 info!
#

_PREC=2
_BASE=1024
_1024=( Bytes KiB MiB GiB TiB PiB EiB ZiB YiB )
_1000=( Bytes KB MB GB TB PB EB ZB YB )
_CHARS="abcdefghijklmnopqrstuvwxyz"

#
1024()
{
	local i; for i in ${_1024[@]}; do
		echo "$i"
	done
}

1000()
{
	local i; for i in ${!_1000[@]}; do
		echo "${_1000[$i]}"
	done
}

#
bytes()
{
	if [[ $# -eq 0 ]]; then
		echo " >> Syntax: bytes <value> [ <base=$_BASE | <unit> [ <prec=$_PREC> ] ]" >&2
		return 1
	elif [[ ! "$1" =~ ^[0-9]+$ ]]; then
		echo " >> Invalid byte count (expecting a positive Integer)" >&2
		return 2
	fi

	local prec=$_PREC
	local base=$_BASE
	local unit=-1

	if [[ $# -ge 2 && -n "$2" ]]; then
		getParams()
		{
			if [[ "${1,,}" == "b" || "${1,,}" == "byte" || "${1,,}" == "bytes" ]]; then
				unit=0
				return
			fi

			for i in ${!_1024[@]}; do
				if [[ "${_1024[$i],,}" == "${1,,}" ]]; then
					unit=$i
					base=1024
					return
				fi
			done
			for i in ${!_1000[@]}; do
				if [[ "${_1000[$i],,}" == "${1,,}" ]]; then
					unit=$i
					base=1000
					return
				fi
			done
			return 1
		}
		
		case "${2,,}" in
			1000|1024)
				base=$2
				unit=-1
				;;
			b|byte|bytes)
				unit=0
				;;
			*)
				getParams "$2"
				if [[ $? -ne 0 ]]; then
					echo " >> Invalid base or unit parameter!" >&2
					return 3
				fi
				;;
		esac
		
		if [[ $# -ge 3 ]]; then
			if [[ ! "$3" =~ ^[0-9]+$ ]]; then
				echo " >> Invalid precision (expecting a positive Integer)" >&2
				return 4
			fi
			$prec=$3
		fi
	fi

	#
	local max=0

	if [[ $base -eq 1024 ]]; then
		max=$((${#_1024[@]}-1))
	elif [[ $base -eq 1000 ]]; then
		max=$((${#_1000[@]}-1))
	else
		max=0
	fi

	#
	local rest=$1
	local index=0
	local int=${rest%%.*}
	
	while [[ $int -ge $base ]]; do
		[[ $index -ge $max ]] && break
		[[ $unit -eq $index ]] && break
		rest="$(bc -l <<<"$rest/$base")"
		int=${rest%%.*}
		let index=$index+1
	done
	
	if [[ $base -eq 1024 ]]; then
		unit="${_1024[$index]}"
	elif [[ $base -eq 1000 ]]; then
		unit="${_1000[$index]}"
	else
		unit="Bytes"
	fi

	#
	[[ $index -eq 0 ]] && prec=0
	
	#
	local result="$(LANG=C printf "%.${prec}f" "${rest/./,}" 2>/dev/null)"
	[[ $? -ne 0 ]] && result="$(LANG=C printf "%.${prec}f" "${rest/,/.}" 2>/dev/null)"
	result="`tryCast $result`"

	#
	echo "$result $unit"
}

#
tryCast()
{
	local result="$1"
	
	if [[ "$result" != *.* ]]; then
		echo "$result"
		return 1
	fi
	
	while [[ "${result: -1}" == "0" ]]; do
		result="${result::-1}"
	done
	
	[[ "${result: -1}" == "." ]] && result="${result::-1}"
	
	echo "$result"
}

#
integer()
{
	# TODO is also here: to handle multiple input values
	# logik ist blosz "${value%%.*}", ohne jede rundung (int-cast styles eben! ;-)
	# rundungen
	echo TODO >&2
	return 255
}

round()
{
	#prec=0 (default)
	# LANG=C printf "%.${prec}f" "${value/./,}"; [[ $? -ne 0 ]] && .. "${value/,/.}"..
	echo TODO >&2
	return 255
}

ceil()
{
	echo TODO >&2
	return 255
}

floor()
{
	echo TODO >&2
	return 255
}

abs()
{
	# bitte MIT (below) "isNumber()" test!
	echo TODO >&2
	return 255
	# nur leading '-' entfernen; von einer liste am besten!?
}

isNegative()
{
	# TODO # bitte MIT isNumber() test!
	# danach nur check if [0]=='-'! ^_^
	# EVTL. auch blosz [[ $var -lt 0 ]];
	# mit '-' string check direkt *alle* initialen '+' und '-'..
	echo TODO >&2
	return 255
}

isPositive()
{
	# TODO # bitte MIT isNumber() test!
	# danach nur check if [0]!='-'! ^_^
	# EVTL. auch blosz [[ $var -ge 0 ]];
	# mit '-' string check direkt *alle* initialen '+' und '-'...
	echo TODO >&2
}

isNumber()
{
	echo TODO >&2
	return 255
	# [[ "$testing" =~ ^[-]?[0-9]+[.]?[0-9]+$ ]];
	# [[ "$testing" =~ ^[-+]*[0-9]+[.]?[0-9]+$ ]];
}

isInt()
{
	echo TODO >&2
	return 255
	# [[ "$var" =~ ^[-]?[0-9]+$ ]];
	# [[ "$var" =~ ^[-+]*[0-9]+$ ]];
}

isFloat()
{
	echo TODO >&2
	return 255
	# [[ "$var" =~ ^[-]?[0-9]+[.][0-9]+$ ]];
	# [[ "$var" =~ ^[-+]*[0-9]+[.][0-9]+$ ]];
}

#
radix()
{
	echo TODO >&2
	return 255
	# radix conversion for the shell! ^_^
}

#
# TODO # 'radix' parameter...?!
#
random()
{
	local max=$1
	local min=$2

	[[ -z "$max" ]] && max=255
	[[ -z "$min" ]] && min=0
	
	if [[ $max -eq $min ]]; then
		echo $max
		return
	elif [[ $max -lt $min ]]; then
		local tmp=$max
		max=$min
		min=$tmp
	fi

	echo "$(((${RANDOM}%(${max}-${min}+1))+${min}))"
}

randomChars()
{
	local length=$1; local result=""
	for i in `seq 1 $length`; do
		result="${result}${_CHARS:$(($RANDOM%${#_CHARS})):1}"
	done; echo $result
}

