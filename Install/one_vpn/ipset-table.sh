#!/bin/sh

PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin

start()
{
	if [ -z "$(ip rule | awk '/^30011/')" ]; then
		ipset create ipset_vpn1 hash:ip
		ip rule add fwmark 1011 table 1011 priority 30011
	fi
}

stop(){
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
