#/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.2.1
# 
# You can either run this file like a regular shell script
# to use it, or you can copy it to `/etc/profile.d/` to get
# the `streaming()` function exported into your environment.
# In this case it's always there, but you just have to call
# the `streaming()` function (by it's name).
#
# My supported methods: [ convert, extract, play, raw ];
#
# Before I'm telling you about the real functionality of this
# script, I want to mention that the function/script should be
# called with the file extensions to look for (from the current
# working directory).. this is a BATCH, so it automates the
# handling of your multimedia files.. I needed it for my own
# A.I. Norbert.. PS: The first parameter needs to be the method
# to use in here.. for more info look below.
#
# At first I needed to convert .mp3 and .ogg to RAW PCM
# audio files. Therefore the `convert` function.
#
# Then I wanted to extract RAW PCM audio data from the
# YouTube videos I downloaded. Therefore `extract`.
#
# The `play` method is similar to `raw`, but holds for
# non-raw audio formats/codecs. This way you could test
# your input files to convert, before they can be played
# via `raw` function after their conversion..
#
# And the last `raw` function is especially for my own A.I.
# Norbert, so that he can pass his output data directly to
# this script, so I'm able to hear what he's telling me!
#
# "RAW PCM" is my default.. best! For other formats and
# more I got some little configuration here (below this);
# but you really should call `man ffmpeg` and adapt this
# script to your needs for yourself. ^_^
#
# BTW: directly below (before the configuration) there's
# a tiny info about the used `ffmpeg` command lines (for
# my three methods mentioned above), jfyi.
#
# ======================================================
# STATUS: TODO! The base methods aren't yet implemented,
# there's only a part of the file functions ready there.
# ======================================================
#

# 
# [convert] `ffmpeg output.raw -i input.mp3 -acodec pcm_s16le -vn` #output.raw`#am ende bisher
# [extract] `ffmpeg output.raw -i input.mp4 -acodec pcm_s16le -vn` #output.raw`#am ende bisher
#    [play] `ffmpeg -i input.ogg -f alsa default`
#     [raw] `ffmpeg -i input.raw -acodec pcm_s16le -vn -ac 2 -ar 44100 -f s16le -f alsa default`
# 

# 
# configuration
#
_HIDE=1				# hide files processed by method [ convert, extract ] (rename to dot-file)
_START=1			# if u start this script `./streaming.sh`.. otherweise exporting the function `streaming()` (/etc/profile.d/)
_INFO=1				# if not starting by calling this script, whether to show a short info that the function is available [now]..
#
_CONVERT_CODEC="pcm_s16le"	# `-acodec pcm_s16le`
_EXTRACT_CODEC="pcm_s16le"	# `-acodec pcm_s16le`
#
_PLAY_CHANNELS=2		# `-ac 2`
_PLAY_OUTPUT="alsa default"	# `-f alsa default`
_PLAY_RAW="s16le"		# `-f s16le`
_PLAY_CODEC="pcm_s16le"		# `-acodec pcm_s16le`

# 
# the main function begins here.
# 
streaming()
{
	#
	FFMPEG="$(which ffmpeg 2>/dev/null)"
	if [[ -z "$FFMPEG" ]]; then
		echo "Unable to find the \`ffmpeg\` tool.. maybe not installed?" >&2
		return 255
	fi

	#
	method="$1"
	shift

	if [[ -z "$method" ]]; then
		echo "Sytanx: \$0 < method >" >&2
		echo
		echo "	Methods: [ convert, extract, play, raw ]" >&2
		echo
		return 1
	fi
}

#
_convert()
{
	echo "TODO" >&2
	return 254
}

_extract()
{
	echo "TODO" >&2
	return 254
}

_play()
{
	echo "TODO" >&2
	return 254
}

_raw()
{
	echo "TODO" >&2
	return 254
}

#
_useExtensions()
{
	ext=("$@")

	i=0; while [[ $i -lt ${#ext[@]} ]]; do
		if [[ -z "${ext[$i]}" ]]; then
			unset 'ext[$i]'
			ext=("${ext[@]}") # array neu indizieren
			continue
		elif [[ "${ext[$i]::1}" != "." ]]; then
			ext[$i]=".${ext[$i]}"
		fi

		_findFiles "${ext[$i]}"

		((++i))
	done
}

_findFiles()
{
	ext="$*"; if [[ -z "$ext" ]]; then
       		echo "Invalid file extension!" >&2
		return 1
	fi; while IFS= read -r -d '' file; do
		if [[ "${file::1}" != "." ]]; then
			_takeFile "$file"
		fi
	done < <(find . -type f -iname "*${ext}" -print0)
}

_takeFile()
{
	file="$*"; if [[ -z "$file" ]]; then
		echo "Missing file path!" >&2
		return 1
	fi
	
	echo "'$file'"
}

#
if [[ $_START -ne 0 ]]; then
	streaming "$@"
elif [[ $_INFO -ne 0 ]]; then
	echo "Function \`streaming()\` ready!"
fi

#
