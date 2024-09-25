#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

if [ "$1" != "-start" ] && [ "$1" != "-stop" ]; then
  [ "$type" == "ip6tables" ] && exit
  [ "$table" != "mangle" ] && exit
  [ -z "$(ip link list | grep $VPN1_NAME)" ] && exit
  [ -z "$(ipset --quiet list ipset_vpn1)" ] && exit
fi

if [ "$1" == "-stop" ]; then CON="! -z" && ACT=D; else CON="-z" && ACT=A; fi

if [ $CON "$(iptables-save | grep ipset_vpn1)" ]; then
  iptables -w -t mangle -$ACT PREROUTING ! -s $VPN1_SUBNET -m conntrack --ctstate NEW -m set --match-set ipset_vpn1 dst -j CONNMARK --set-mark 1011
  iptables -w -t mangle -$ACT PREROUTING ! -s $VPN1_SUBNET -m set --match-set ipset_vpn1 dst -j CONNMARK --restore-mark
fi