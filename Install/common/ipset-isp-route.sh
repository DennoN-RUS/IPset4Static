#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

if [ "$1" != "-start" ] && [ "$1" != "-stop" ]; then
  [ "$1" == "hook" ] || exit 0
  [ "$system_name" == "$ISP_NAME" ] || exit 0
  [ ! -z "$(ipset --quiet list ipset_isp1)" ] || exit 0
  [ "${connected}-${link}-${up}" == "yes-up-up" ] || exit 0
fi

if [ "$1" == "-stop" ]; then
  if [ -n "$(ip route list table 1010)" ]; then
    ip route flush table 1010
  fi
  exit 0
fi

if [ -z "$(ip route list table 1010)" ]; then
  if [ -z "$ISP_GW" ]; then 
    ip route add default dev $ISP_NAME table 1010
  else
    ip route add default via $ISP_GW table 1010
  fi
fi