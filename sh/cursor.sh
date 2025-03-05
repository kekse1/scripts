#!/usr/bin/env bash

#
# Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.2
#

cursor()
{
	local trash; local result;
	echo -ne "\e[6n"
	read -s -d\[ trash
	read -s -d R result
	echo "$(echo "$result" | tr ";" " ")"
}

