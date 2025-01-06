#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://norbert.com.es/
#

#
OUTPUT=( PATH NAME SIZE SERIAL UUID PARTUUID PTUUID LABEL PARTLABEL )

#
LSBLK="lsblk"
LSBLK="$(which $LSBLK 2>/dev/null)"

#
if [[ $? -ne 0 ]]; then
	echo "Command \`lsblk\` not found. Try \`apt install util-linux blk-utils\`." >&2
	exit 4
fi

MAX_LEN=0
for i in "${OUTPUT[@]}"; do
	len="${#i}"
	[[ $MAX_LEN -lt $len ]] && MAX_LEN=$len
done
let MAX_LEN=$MAX_LEN+2

#
diskSize()
{
	if [[ -z "$1" ]]; then
		echo "First parameter needs to be an existing device." >&2
		return 255
	fi

	path="$1"

	if [[ "${path::1}" != "/" ]]; then
		path="$(findDisk "$path")"
	elif [[ ! -e "$path" ]]; then
		echo "This device path doesn't exist." >&2
		return 254
	fi

	SIZE="$($LSBLK --bytes --pairs --output size "$path")"
	SIZE="${SIZE#*=}"
	SIZE="${SIZE#\"}"
	SIZE="${SIZE%\"}"

	if [[ -z $2 ]]; then
		echo "$SIZE"
	elif [[ $SIZE -ne $2 ]]; then
		echo "Sizes doesn't match. That's critical!" >&2
		return 2
	fi
}

diskInfo()
{
	if [[ -z "$1" ]]; then
		echo "First parameter needs to be an existing device." >&2
		return 255
	fi

	path="$1"

	if [[ "${path::1}" != "/" ]]; then
		path="$(findDisk "$path")"
	elif [[ ! -e "$path" ]]; then
		echo "This device path doesn't exist." >&2
		return 254
	fi

	size=""
	sep="$2"; [[ -z "$sep" ]] && sep=" "
	output="$($LSBLK --bytes --pairs --output path,size "$path")"
	output=( $output )
	
	for pair in "${output[@]}"; do
		key="${pair%%=*}"
		value="${pair#*=}"
		value="${value#\"}"
		value="${value%\"}"
		
		case "$key" in
			PATH) path="$value";;
			SIZE) size=$value;;
		esac
	done
	
	echo "${path}${sep}${size}"
}

findDisk()
{
	if [[ -z "$1" ]]; then
		echo "Please argue with your disk identifier (and optionally a size to compare, for security reasons)." >&2
		return 1
	fi

	verbose=0; [[ -n "$3" ]] && verbose=1
	verboseExtra=0; [[ -n "$4" ]] && verboseExtra=1

	_IFS="$IFS"; IFS=','; cmd="${LSBLK} --bytes --pairs --output ${OUTPUT[*]} 2>/dev/null"; IFS="$_IFS"
	output="$(eval "$cmd" | grep -i "$1")"

	if [[ $? -ne 0 ]]; then
		echo "Unable to find drive/partition parameters!" >&2
		return 2
	elif [[ -n "$2" && `echo "$output" | wc -l` -ne 1 ]]; then
		echo "Either we found no item or too many (we need exactly one)!" >&2
		return 3
	fi
	
	result=''
	output=( $output )
	match=""

	for pair in "${output[@]}"; do
		key="${pair%%=*}"
		value="${pair#*=}"
		value="${value#\"}"
		value="${value%\"}"
		
		if [[ -z "$match" ]]; then
			if [[ "$value" == "$1" ]]; then
				match="$key"
			fi
		fi

		[[ $verbose -ne 0 ]] && printf "%${MAX_LEN}s: %s\n" "$key" "$value"

		case "$key" in
			SIZE)
				if [[ -n "$2" && $value -ne $2 ]]; then
					echo "Your configured size doesn't match. Critical!" >&2
					return 4
				fi
				;;
			PATH)
				if [[ -z "$value" ]]; then
					echo "Real path couldn't be resolved.. too bad." >&2
					return 5
				else
					result="$value"
				fi
				;;
		esac
	done
	
	if [[ -n "$2" && -z "$match" ]]; then
		echo "After checking twice, your disk identifier was not in any output element." >&2
		return 6
	fi
	
	[[ $verboseExtra -ne 0 && -n "$match" ]] && echo "Your disk identifier parameter was found within the key '$match'"

	if [[ -n "$result" ]]; then
	       echo "$result"
	       return 0
       else
	       return 255
	fi
}

#
