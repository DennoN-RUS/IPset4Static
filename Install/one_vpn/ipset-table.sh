#!/bin/sh

PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin

start(){
  #VPN1
  if [ -z "$(ipset list | grep ipset_vpn1)" ]; then ipset create ipset_vpn1 hash:ip; fi
  if [ -z "$(ip rule | awk '/^30011/')" ]; then ip rule add fwmark 1011 table 1011 priority 30011; fi
  sh SYSTEMFOLDERINPUT/etc/ndm/ifstatechanged.d/011-ipset-vpn1-route.sh -start
  sh SYSTEMFOLDERINPUT/etc/ndm/netfilter.d/011-ipset-vpn1-netfilter.sh -start
  #ISP
  if [ -z "$(ipset list | grep ipset_isp1)" ]; then ipset create ipset_isp1 hash:ip; fi
  if [ -z "$(ip rule | awk '/^30010/')" ]; then ip rule add fwmark 1010 table 1010 priority 30010; fi
  sh SYSTEMFOLDERINPUT/etc/ndm/ifstatechanged.d/012-ipset-isp-route.sh -start
  sh SYSTEMFOLDERINPUT/etc/ndm/netfilter.d/012-ipset-isp-netfilter.sh -start
}

stop(){
  #VPN1
  if [ -n "$(ipset list | grep ipset_vpn1)" ]; then ipset flush ipset_vpn1; fi
  if [ -n "$(ip rule | awk '/^30011/')" ]; then ip rule del table 1011; fi
  #ISP
  if [ -n "$(ipset list | grep ipset_isp1)" ]; then ipset flush ipset_isp1; fi
  if [ -n "$(ip rule | awk '/^30010/')" ]; then ip rule del table 1010; fi
}
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
    sleep 5
    start
  ;;
  *)
  echo "Usage: $0 {start|stop|kill|restart}"
;;
esac 
