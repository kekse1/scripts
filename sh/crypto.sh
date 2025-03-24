#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.3
#
# Manage LUKS encryption via `cryptsetup` (dependency).
#
# My aim is to transparently `cmount` or `cumount`, plus
# the initial format/preparation of crypto devices/mounts.
#
# STILL only **TODO**!!111
#

#
__crypto_cryptsetup="cryptsetup"
__crypto_error_cryptsetup_not_found="The \`cryptsetup\` utility doesn't seem to be installed on your system!"
__crypto_error_invalid_device="Invalid \`device\` parameter, maybe it doesn't exist (a file path, probably a block device)!"
__crypto_error_invalid_mount="Invalid \`mount point\` parameter; maybe there's no such *directory*!"

#
cryptoFormat()
{
	local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
		echo "[ERROR] ${__crypto_error_cryptsetup_not_found}" >&2; return 1; fi
	local DEVICE="$1"; if [[ -z "$DEVICE" || ! -e "$DEVICE" ]]; then
		echo "[ERROR] ${__crypto_error_invalid_device}" >&2; return 2; fi
	local CMD="${CRYPTSETUP} luksFormat"
	CMD="${CMD} --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 512 --iter-time 3000 --use-urandom --verify-passphrase" # "--pbkdf {argon2id,pbkdf2}"
	CMD="${CMD} ${DEVICE}"
}

cmount()
{
	local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
		echo "[ERROR] ${__crypto_error_cryptsetup_not_found}" >&2; return 1; fi
	local DEVICE="$1"; if [[ -z "$DEVICE" || ! -e "$DEVICE" ]]; then
		echo "[ERROR] ${__crypto_error_invalid_device}" >&2; return 2; fi
	local MOUNT="$2"; if [[ -z "$MOUNT" || ! -d "$MOUNT" ]]; then
		echo "[ERROR] ${__crypto_error_invalid_mount}" >&2; return 3; fi
	local CMD="${CRYPTSETUP}"
}

cumount()
{
	local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
		echo "[ERROR] ${__crypto_error_cryptsetup_not_found}" >&2; return 1; fi
	local DEVICE="$1"; if [[ -z "$DEVICE" || ! -e "$DEVICE" ]]; then
		echo "[ERROR] ${__crypto_error_invalid_device}" >&2; return 2; fi
	local MOUNT="$2"; if [[ -z "$MOUNT" || ! -d "$MOUNT" ]]; then
		echo "[ERROR] ${__crypto_error_invalid_mount}" >&2; return 3; fi
	local CMD="${CRYPTSETUP}"
}

#

