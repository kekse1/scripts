#!/usr/bin/env bash
#
# This is a test.
#
# v0.0.2
#
# Found the original function here (and I really like it!):
# https://github.com/physicsdolphin/nv-uefi-unlocker/blob/main/release/make-usbroot.sh
#
# w/ just a little extension. Keks. ;-)
#
# https://kekse.biz/
# https://github.com/kekse1/
#

usage()
{
	awk 'NR > 1 { if ($0 !~ /^#/) exit; sub(/^# ?/, ""); print }' "$0"
	[[ -n $1 ]] && exit $1
	true
}

usage

