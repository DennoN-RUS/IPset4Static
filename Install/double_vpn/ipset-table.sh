#!/bin/sh

PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin

. SYSTEMFOLDERINPUT/etc/ipset4static.conf

start(){
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
	if [ -z "$(ip rule | awk '/^30012/')" ]; then
		ipset create ipset_vpn2 hash:ip
		ip rule add fwmark 1012 table 1012 priority 30012
		ip route add default dev $VPN2_NAME table 1012
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
	if [ -n "$(ip rule | awk '/^30012/')" ]; then
		ipset destroy ipset_vpn2
		ip rule del table 1012
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
