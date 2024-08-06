#!/bin/sh

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

[ "$type" == "ip6tables" ] && exit
[ "$table" != "mangle" ] && exit
[ -z "$(ip link list | grep $VPN1_NAME)" ] && exit
[ -z "$(ipset --quiet list ipset_vpn1)" ] && exit

if [ -z "$(iptables-save | grep ipset_vpn1)" ]; then
     iptables -w -t mangle -A PREROUTING ! -s $VPN1_SUBNET -m conntrack --ctstate NEW -m set --match-set ipset_vpn1 dst -j CONNMARK --set-mark 1011
     iptables -w -t mangle -A PREROUTING ! -s $VPN1_SUBNET -m set --match-set ipset_vpn1 dst -j CONNMARK --restore-mark
fi