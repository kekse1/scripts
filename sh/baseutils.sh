#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
# https://kekse.biz/ https://github.com/kekse1/scripts/
# v0.1.2
#

mkcd()
{
	if [ $# -eq 0 ]; then
		echo "Syntax: mkcd <directory>" >&2
		return 1
	fi
	mkdir -pv "$*" || return $?
	cd "$*"
	pwd
}

extname()
{
	//my own version w/ $count argument
}

random()
{
	//$RANDOM w/ $radix..
}

eol()
{
	//using $count
}

line()
{
	//with $str, using width() (below)
}

width()
{
	if [[ -n "$COLUMNS" ]]; then
		echo $COLUMNS
	else
		tput cols
	fi
}

height()
{
	if [[ -n "$LINES" ]]; then
		echo $LINES
	else
		tput lines
	fi
}

abs()
{
	// nur leading '-' entfernen; von einer liste am besten!?
}

round()
{
	// `printf "%.${prec}f" $val
}

pad()
{
	//am einfachsten `printf` nutzen, hm?
	//sonst selbst machen.. ^_^
}

repeat()
{
	//`repeat $count $*`
	//vs. stdin '-'!??
}

yesno()
{
	//ask as long as no real "y[es]/n[o]"!
}

random()
{
	// <max> <min> <radix> // even a list possible via 4th <count>?!
}

radix()
{
	//radix conversion for the shell! ^_^
}
