#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

if [ "$1" != "-start" ]; then
  [ "$type" == "ip6tables" ] && exit
  [ "$table" != "mangle" ] && exit
  [ -z "$(ip link list | grep $VPN2_NAME)" ] && exit
  [ -z "$(ipset --quiet list ipset_vpn2)" ] && exit
fi

if [ -z "$(iptables-save | grep ipset_vpn2)" ]; then
  iptables -w -t mangle -A PREROUTING ! -s $VPN2_SUBNET -m conntrack --ctstate NEW -m set --match-set ipset_vpn2 dst -j CONNMARK --set-mark 1012
  iptables -w -t mangle -A PREROUTING ! -s $VPN2_SUBNET -m set --match-set ipset_vpn2 dst -j CONNMARK --restore-mark
fi