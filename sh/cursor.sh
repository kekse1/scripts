#!/usr/bin/env bash

#
# Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.0.1
#

cursor()
{
	echo -ne "\e[6n"
	read -s -d\[ trash
	read -s -d R result
	echo "$(echo "$result" | tr ";" " ")"
}

