#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

[ "$1" == "hook" ] || exit 0
[ "$system_name" == "$VPN2_NAME" ] || exit 0
[ ! -z "$(ipset --quiet list ipset_vpn2)" ] || exit 0
[ "${connected}-${link}-${up}" == "yes-up-up" ] || exit 0

if [ -z "$(ip route list table 1012)" ]; then
    ip route add default dev $system_name table 1012
    
fi