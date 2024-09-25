#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

if [ "$1" != "-start" ] && [ "$1" != "-stop" ]; then
  [ "$type" == "ip6tables" ] && exit
  [ "$table" != "mangle" ] && exit
  [ -z "$(ip link list | grep $ISP_NAME)" ] && exit
  [ -z "$(ipset --quiet list ipset_isp1)" ] && exit
fi

if [ "$1" == "-stop" ]; then CON="! -z" && ACT=D; else CON="-z" && ACT=A; fi

if [ $CON "$(iptables-save | grep ipset_isp1)" ]; then
  iptables -w -t mangle -$ACT PREROUTING ! -s $ISP_SUBNET -m conntrack --ctstate NEW -m set --match-set ipset_isp1 dst -j CONNMARK --set-mark 1010
  iptables -w -t mangle -$ACT PREROUTING ! -s $ISP_SUBNET -m set --match-set ipset_isp1 dst -j CONNMARK --restore-mark
fi