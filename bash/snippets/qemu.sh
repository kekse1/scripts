#!/usr/bin/env bash
#
# Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
#
# Most common parameters here, to easily start `qemu`.
#

MEM="4G"
CPU="host"
KEY="de"
VGA="virtio"
FORMAT="raw"
UEFI="" #/usr/share/qemu/OVMF.fd" # `apt install ovmf`..
HDA="$1"
ROM="$2"
BOOT="" # d = ROM, c = HDA...

EMU="qemu-system-x86_64"
EMU="`which $EMU 2>/dev/null`"

if [ -z "$EMU" ]; then
	echo -e " >> QEMU binary not found (\`qemu-system-x86_64\`)!" >&2
	exit 1
fi

if [ $# -lt 1 ]; then
	echo -e "Syntax: $0 <image> [ <cdrom> ]" >&2
	exit 2
fi

uefi=""
[[ -n "$UEFI" ]] && uefi="-bios '$UEFI'"

CMD="$EMU $uefi -enable-kvm -m $MEM -cpu $CPU -k $KEY -vga $VGA -drive format=$FORMAT,index=0,format=raw,file='$HDA'"
[ -n "$ROM" ] && CMD="$CMD -cdrom '$ROM'"
[ -n "$BOOT" ] && CMD="$CMD -boot $BOOT"

echo " >> '$CMD'"
eval "$CMD"

