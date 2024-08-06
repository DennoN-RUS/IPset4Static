#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

if [ "$1" != "-start" ]; then
  [ "$1" == "hook" ] || exit 0
  [ "$system_name" == "$VPN2_NAME" ] || exit 0
  [ ! -z "$(ipset --quiet list ipset_vpn2)" ] || exit 0
  [ "${connected}-${link}-${up}" == "yes-up-up" ] || exit 0
fi

if [ -z "$(ip route list table 1012)" ]; then
  ip route add default dev $VPN2_NAME table 1012
fi