#!/usr/bin/env bash

# 
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/
# 

# 
# FYI: You can limit the power usage:
# 
# # echo 125000000 >"/sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw"
# # # .. set's the limit to 125 Watt!
# 
# You can also `crontab -e` and append the above line plus the prefix `@reboot `.
# 
# To Fine-tune: `watch -n 1 "grep MHz /proc/cpuinfo"`.
# 

_seconds=10

#
[[ -n "$1" ]] && _seconds=$1
echo -e "Calculating the Watt's in $_seconds seconds..\n"

a="$(grep . /sys/class/powercap/intel-rapl\:0/energy_uj)" || exit 234
sleep ${_seconds}s || exit 123
b="$(grep . /sys/class/powercap/intel-rapl\:0/energy_uj)"

echo -e "\t(a) $a\n\t(b) $b"

((div=(1000000*_seconds)))
((watt=(b-a)/div))

echo -e "( ( $b - $a) / $div )\n"
echo -e "  => ~$watt Watt\n"

echo -e "       kWh per hour: a = ( $watt / 1000 )"
echo -e "Price (0.35€ / kWh): b = ( a * 0.35 )"

