#!/bin/sh

PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin
. SYSTEMFOLDERINPUT/etc/ipset4static.conf

start(){
  #VPN2
  if [ -z "$(ipset list | grep ipset_vpn2)" ]; then ipset create ipset_vpn2 hash:ip timeout $TTL; fi
  if [ -z "$(ip rule | awk '/^30012/')" ]; then ip rule add fwmark 1012 table 1012 priority 30012; fi
  sh SYSTEMFOLDERINPUT/etc/ndm/ifstatechanged.d/010-ipset-vpn2-route.sh -start
  sh SYSTEMFOLDERINPUT/etc/ndm/netfilter.d/010-ipset-vpn2-netfilter.sh -start
  #VPN1
  if [ -z "$(ipset list | grep ipset_vpn1)" ]; then ipset create ipset_vpn1 hash:ip timeout $TTL; fi
  if [ -z "$(ip rule | awk '/^30011/')" ]; then ip rule add fwmark 1011 table 1011 priority 30011; fi
  sh SYSTEMFOLDERINPUT/etc/ndm/ifstatechanged.d/011-ipset-vpn1-route.sh -start
  sh SYSTEMFOLDERINPUT/etc/ndm/netfilter.d/011-ipset-vpn1-netfilter.sh -start
  #ISP
  if [ -z "$(ipset list | grep ipset_isp1)" ]; then ipset create ipset_isp1 hash:ip timeout $TTL; fi
  if [ -z "$(ip rule | awk '/^30010/')" ]; then ip rule add fwmark 1010 table 1010 priority 30010; fi
  sh SYSTEMFOLDERINPUT/etc/ndm/ifstatechanged.d/012-ipset-isp-route.sh -start
  sh SYSTEMFOLDERINPUT/etc/ndm/netfilter.d/012-ipset-isp-netfilter.sh -start
}

stop(){
  #VPN2
  sh SYSTEMFOLDERINPUT/etc/ndm/netfilter.d/010-ipset-vpn2-netfilter.sh -stop
  sh SYSTEMFOLDERINPUT/etc/ndm/ifstatechanged.d/010-ipset-vpn2-route.sh -stop
  if [ -n "$(ip rule | awk '/^30012/')" ]; then ip rule del table 1012; fi
  if [ -n "$(ipset list | grep ipset_vpn2)" ]; then ipset destroy ipset_vpn2; fi
  #VPN1
  sh SYSTEMFOLDERINPUT/etc/ndm/netfilter.d/011-ipset-vpn1-netfilter.sh -stop
  sh SYSTEMFOLDERINPUT/etc/ndm/ifstatechanged.d/011-ipset-vpn1-route.sh -stop
  if [ -n "$(ip rule | awk '/^30011/')" ]; then ip rule del table 1011; fi
  if [ -n "$(ipset list | grep ipset_vpn1)" ]; then ipset destroy ipset_vpn1; fi
  #ISP
  sh SYSTEMFOLDERINPUT/etc/ndm/netfilter.d/012-ipset-isp-netfilter.sh -stop
  sh SYSTEMFOLDERINPUT/etc/ndm/ifstatechanged.d/012-ipset-isp-route.sh -stop
  if [ -n "$(ip rule | awk '/^30010/')" ]; then ip rule del table 1010; fi
  if [ -n "$(ipset list | grep ipset_isp1)" ]; then ipset destroy ipset_isp1; fi
}

case "$1" in
  start)
    start
  ;;
  stop | kill)
    stop
  ;;
  restart)
    stop
    sleep 2
    start
  ;;
  *)
  echo "Usage: $0 {start|stop|kill|restart}"
;;
esac 
