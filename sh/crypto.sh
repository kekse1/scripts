#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.1
#
# Manage LUKS encryption via `cryptsetup` (dependency).
#
# STILL **TODO**!111
#

#
__crypto_cryptsetup="cryptsetup"
__crypto_error_cryptsetup_not_found="The \`cryptsetup\` utility doesn't seem to be installed on your system!"

#
cryptoFormat()
{
	local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
		echo "[ERROR] ${__crypto_error_cryptsetup_not_found}"; return 1; fi
	local CMD="${CRYPTSETUP} luksFormat"
	CMD="${CMD} --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 512 --iter-time 3000 --use-urandom --verify-passphrase" # "--pbkdf {argon2id,pbkdf2}"
	#CMD="${CMD} ${DEVICE}"
}

cryptoStart()
{
	local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
		echo "[ERROR] ${__crypto_error_cryptsetup_not_found}"; return 1; fi
	local CMD="${CRYPTSETUP}"
}

cryptoStop()
{
	local CRYPTSETUP="$(which "${__crypto_cryptsetup}" 2>/dev/null)"; if [[ -z "$CRYPTSETUP" ]]; then
		echo "[ERROR] ${__crypto_error_cryptsetup_not_found}"; return 1; fi
	local CMD="${CRYPTSETUP}"
}

#

