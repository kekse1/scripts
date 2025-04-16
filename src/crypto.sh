#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.6
#
# Manage LUKS encryption via `cryptsetup` (dependency).
#
# My aim is to transparently `cmount` or `cumount`, plus
# the initial format/preparation of crypto devices/mounts.
#
# STILL only **TODO**!!111
#

#
crypto()
{
	#
	local __crypto_cryptsetup="cryptsetup"
	local __crypto_error_cryptsetup_not_found="The \`cryptsetup\` utility doesn't seem to be installed on your system!"
	local __crypto_error_invalid_device="Invalid \`device\` parameter, maybe it doesn't exist (a file path, probably a block device)!"
	local __crypto_error_invalid_mount="Invalid \`mount point\` parameter; maybe there's no such *directory*!"

	#
	cformat()
	{
echo "format($#)" >&2; return 255;

		local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
			echo "[ERROR] ${__crypto_error_cryptsetup_not_found}" >&2; return 1; fi
		local DEVICE="$1"; if [[ -z "$DEVICE" || ! -e "$DEVICE" ]]; then
			echo "[ERROR] ${__crypto_error_invalid_device}" >&2; return 2; fi
		local CMD="${CRYPTSETUP} luksFormat"
		CMD="${CMD} --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 512 --iter-time 2560 --use-urandom --verify-passphrase --pbkdf argon2id"
		CMD="${CMD} ${DEVICE}"

		# todo # 'mkfs....'!
	}

	clist()
	{
echo "list($#)" >&2; return 255;

		local CMD="cat /proc/crypto"
	}

	cinfo()
	{
echo "info($#)" >&2; return 255;

		false
		# `cryptsetup -v status $NAME`
	}

	cmount()
	{
echo "mount($#)" >&2; return 255;

		local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
			echo "[ERROR] ${__crypto_error_cryptsetup_not_found}" >&2; return 1; fi
		local DEVICE="$1"; if [[ -z "$DEVICE" || ! -e "$DEVICE" ]]; then
			echo "[ERROR] ${__crypto_error_invalid_device}" >&2; return 2; fi
		local MOUNT="$2"; if [[ -z "$MOUNT" || ! -d "$MOUNT" ]]; then
			echo "[ERROR] ${__crypto_error_invalid_mount}" >&2; return 3; fi
		local NAME="$(basename "$MOUNT")"
		local MAPPER="/dev/mapper/${NAME}"
		local CMD1="${CRYPTSETUP} luksOpen '$DEVICE' '${NAME}'"
		local CMD2="mount '${MAPPER}' '${MOUNT}'"
	}

	cumount()
	{
echo "umount($#)" >&2; return 255;

		local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
			echo "[ERROR] ${__crypto_error_cryptsetup_not_found}" >&2; return 1; fi
		local DEVICE="$1"; if [[ -z "$DEVICE" || ! -e "$DEVICE" ]]; then
			echo "[ERROR] ${__crypto_error_invalid_device}" >&2; return 2; fi
		local MOUNT="$2"; if [[ -z "$MOUNT" || ! -d "$MOUNT" ]]; then
			echo "[ERROR] ${__crypto_error_invalid_mount}" >&2; return 3; fi
		local NAME="$(basename "$MOUNT")"
		local CMD2="${CRYPTSETUP} luksClose '${NAME}'"
		local CMD1="umount '${MOUNT}'"
	}

	#
	local function="${1,,}"; shift;
	case "$function" in
		format|cformat)
			cformat "$@"
			return $?
			;;
		list|clist)
			clist "$@"
			return $?
			;;
		info|cinfo)
			cinfo "$@"
			return $?
			;;
		mount|cmount)
			cmount "$@"
			return $?
			;;
		umount|cumount|unmount|cunmount)
			cumount "$@"
			return $?
			;;
		*)
			echo "ERROR: Invalid function!" >&2
			echo -e "\t[ format, list, info, mount, umount ]" >&2
			return 255
			;;
	esac
}

#

