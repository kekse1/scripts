# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.1
#
# Copy to '/etc/profile.d/` to automatically include
# the following functions .. read the source 4 info!
#

# size
_PREC=2
_BASE=1024
_1024=( Bytes KiB MiB GiB TiB PiB EiB ZiB YiB )
_1000=( Bytes KB MB GB TB PB EB ZB YB )

#
1024()
{
	for i in ${_1024[@]}; do
		echo "$i"
	done
}

1000()
{
	for i in ${!_1000[@]}; do
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

	prec=$_PREC
	base=$_BASE
	unit=-1

	if [[ $# -ge 2 && -n "$2" ]]; then
		getParams()
		{
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
	rest=$1
	index=0
	int=${rest%%.*}
	
	while [[ $int -ge $base ]]; do
		[[ $unit -eq $index ]] && break
		rest="$(bc -l <<<"$rest/$base")"
		int=${rest%%.*}
		let index=$index+1
	done
	
	if [[ $base -eq 1000 ]]; then
		unit="${_1000[$index]}"
	else
		unit="${_1024[$index]}"
	fi
	
	#
	LANG=C printf "%.${prec}f ${unit}\n" $rest
}

#
parseSeconds()
{
	if [[ $# -ne 1 || ! "$1" =~ ^[0-9]+$ ]]; then
		echo " >> Invalid parameter (expecting positive integer)!" >&2
		return 1
	fi
	
	s=$(($1%60))
	m="$(bc <<<"$1/60%60")"
	m=${m%%.*}
	h=$(bc <<<"$1/3600")
	h=${h%%.*}
	
	printf "%02d:%02d:%02d\n" $h $m $s
}

getDay()
{
	h=0
	m=0
	s=0

	if [[ $# -eq 1 ]]; then
		if [[ "$1" =~ ":" ]]; then
			h=`echo $1 | cut -d: -f1`
			m=`echo $1 | cut -d: -f2`
			s=`echo $1 | cut -d: -f3`
		elif [[ "$1" =~ ^[0-9]+$ ]]; then
			s=$(($1%60))
			m="$(bc <<<"$1/60%60")"
			m=${m%%.*}
			h=$(bc <<<"$1/3600")
			h=${h%%.*}
		else
			echo " >> Invalid parameters!" >&2
			return 1
		fi
	else
		h=$1
		m=$2
		s=$3
	fi

	ch=`date +%H`
	cm=`date +%M`
	cs=`date +%S`

	while [[ "${ch::1}" == "0" && ${#ch} -gt 1 ]]; do ch="${ch:1}"; done
	while [[ "${cm::1}" == "0" && ${#cm} -gt 1 ]]; do cm="${cm:1}"; done
	while [[ "${cs::1}" == "0" && ${#cs} -gt 1 ]]; do cs="${cs:1}"; done
	
	while [[ "${h::1}" == "0" && ${#h} -gt 1 ]]; do h="${h:1}"; done
	while [[ "${m::1}" == "0" && ${#m} -gt 1 ]]; do m="${m:1}"; done
	while [[ "${s::1}" == "0" && ${#s} -gt 1 ]]; do s="${s:1}"; done

	[[ -z "$h" ]] && h=$ch
	[[ -z "$m" ]] && m=$cm
	[[ -z "$s" ]] && s=$cs

	while [[ "${h::1}" == "0" && ${#h} -gt 1 ]]; do h="${h:1}"; done
	while [[ "${m::1}" == "0" && ${#m} -gt 1 ]]; do m="${m:1}"; done
	while [[ "${s::1}" == "0" && ${#s} -gt 1 ]]; do s="${s:1}"; done

	if [[ $h -eq $ch && $m -eq $cm && $s -eq $cs ]]; then
		h=$ch
		m=$cm
		s=$cs
	fi

	if [[ ! "$h" =~ ^[0-9]+$ ]]; then
		echo " >> Hour component is invalid (no positive Integer)" >&2
		return 2
	elif [[ ! "$m" =~ ^[0-9]+$ ]]; then
		echo " >> Minute component is invalid (no positive Integer)" >&2
		return 3
	elif [[ ! "$s" =~ ^[0-9]+$ ]]; then
		echo " >> Hour component is invalid (no positive Integer)" >&2
		return 4
	else
		h=$(($h%24))
		m=$(($m%60))
		s=$(($s%60))
	fi
	
	seconds=$((($h*60*60)+($m*60)+$s))
	printf "%02d:%02d:%02d\n%ds\n" $h $m $s $seconds
}

getTime()
{
	res="getDay"; for i in "$@"; do res="${res} '$i'"; done
	res="$(eval "$res")"
	res="`echo \"$res\" | cut -d$'\n' -f1`"
	echo "$res"
}

getSeconds()
{
	res="getDay"; for i in "$@"; do res="${res} '$i'"; done
	res="$(eval "$res")"
	res="`echo \"$res\" | cut -d$'\n' -f2`"
	echo "${res:: -1}"
}

#
