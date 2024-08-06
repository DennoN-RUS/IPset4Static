#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

[ "$1" == "hook" ] || exit 0
[ "$system_name" == "$ISP_NAME" ] || exit 0
[ ! -z "$(ipset --quiet list ipset_isp1)" ] || exit 0
[ "${connected}-${link}-${up}" == "yes-up-up" ] || exit 0

if [ -z "$(ip route list table 1010)" ]; then
    ip route add default dev $system_name table 1010
fi