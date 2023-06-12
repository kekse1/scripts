#!/usr/bin/env bash
#
# <kuchen@kekse.biz>
#
# Just an example of "substr(ing)" in (bash) shell scripting..
#


_string="0123456789"

echo -e "The example string is '$_string'. Let's try:\n"

echo -en '\t${_string:2:3}\t\t'
echo -e "${_string:2:3}\n"

echo -en '\t${_string::-2}\t\t'
echo -e "${_string::-2}\n"

echo -en '\t${_string:2}\t\t'
echo -e "${_string:2}\n"

echo -en '\t${_string::2}\t\t'
echo -e "${_string::2}\n"

echo -en '\t${_string:2:-3}\t\t'
echo -e "${_string:2:-3}\n"

echo -en '\t${_string:-3}\t\t'
echo -e "${_string:-3}\n"

echo -en '\t${_string:-2:3}\t\t'
echo -e "${_string:-2:3}\n"

echo -en '\t${_string:-2:-3}\t'
echo -e "${_string:-2:-3}\n"

echo -en '\t${_string: -2}\t\t'
echo -e "${_string: -2}\n"

