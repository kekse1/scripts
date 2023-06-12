#!/usr/bin/env bash
# <kuchen@kekse.biz>

rand()
{
	max=1
	min=0

	[[ -n $1 ]] && max=$1
	[[ -n $2 ]] && min=$2

	echo "$((($RANDOM % ($max - $min + 1)) + $min))"
}

