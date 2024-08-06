#!/bin/sh

PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

start()
{
	if [ -z "$(ip rule | awk '/^30010/')" ]; then
		ipset create ipset_isp hash:ip
		ip rule add fwmark 1010 table 1010 priority 30010
		ip route add default dev $ISP_NAME table 1010
	fi
	if [ -z "$(ip rule | awk '/^30011/')" ]; then
		ipset create ipset_vpn1 hash:ip
		ip rule add fwmark 1011 table 1011 priority 30011
		ip route add default dev $VPN1_NAME table 1011
	fi
}

stop(){
	if [ -n "$(ip rule | awk '/^30010/')" ]; then
		ipset destroy ipset_isp
		ip rule del table 1010
	fi
	if [ -n "$(ip rule | awk '/^30011/')" ]; then
		ipset destroy ipset_vpn1
		ip rule del table 1011
	fi
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
