#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

if [ "$1" != "-start" ]; then
  [ "$1" == "hook" ] || exit 0
  [ "$system_name" == "$VPN1_NAME" ] || exit 0
  [ ! -z "$(ipset --quiet list ipset_vpn1)" ] || exit 0
  [ "${connected}-${link}-${up}" == "yes-up-up" ] || exit 0
fi

if [ -z "$(ip route list table 1011)" ]; then
    ip route add default dev $VPN1_NAME table 1011
fi