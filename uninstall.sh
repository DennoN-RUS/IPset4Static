#!/bin/sh

ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"` && HOME_FOLDER_SED=$(echo $HOME_FOLDER | sed 's/\//\\\//g')
LISTS=$HOME_FOLDER/lists
SCRIPTS=$HOME_FOLDER/scripts
SYSTEM_FOLDER=`echo $HOME_FOLDER | awk -F/opt '{print $1}'`
SYSTEM_FOLDER=$SYSTEM_FOLDER/opt && SYSTEM_FOLDER_SED=$(echo $SYSTEM_FOLDER | sed 's/\//\\\//g')

SCRIPTS=$HOME_FOLDER/scripts

while true; do
    echo "Begin uninstall? y/n"
    read yn
    case $yn in
        [Yy]* )

if [ $(echo $ABSOLUTE_FILENAME | grep -c Bird4Static) -eq 1 ]; then Bird4Static=1; else Bird4Static=0; fi

# Stop Services
$SYSTEM_FOLDER/etc/init.d/S03ipset-table stop

# Remove packages
# ipset
answer=0; echo "Do you want remove 'ipset'? 0 - no 1 - yes (default: no)"; read answer
if [ "$answer" = "1" ]; then $SYSTEM_FOLDER/bin/opkg remove ipset; fi
# iptables
answer=0; echo "Do you want remove 'iptables'? 0 - no 1 - yes (default: no)"; read answer
if [ "$answer" = "1" ]; then $SYSTEM_FOLDER/bin/opkg remove iptables; fi
# diff and patch
answer=0; echo "Do you want remove 'diffutils' and 'patch'? 0 - no 1 - yes (default: no)"; read answer
if [ "$answer" = "1" ]; then $SYSTEM_FOLDER/bin/opkg remove diffutils patch; fi

# Remove DNS Settings
if [ $(cat $SYSTEM_FOLDER/etc/dnsmasq.conf | grep conf-file=$SYSTEM_FOLDER/etc/ipset4static_list.conf -c ) -eq 1 ]; then
  sed -i '/conf-file='$SYSTEM_FOLDER_SED'\/etc\/ipset4static_list.conf/d' $SYSTEM_FOLDER/etc/dnsmasq.conf
  $SYSTEM_FOLDER/etc/init.d/S56dnsmasq restart
elif [ $(cat $SYSTEM_FOLDER/etc/AdGuardHome/AdGuardHome.yaml | grep "ipset_file: $SYSTEM_FOLDER/etc/ipset4static_list.conf" -c ) -eq 1 ]; then
   sed -i 's/ipset_file: '$SYSTEM_FOLDER_SED'\/etc\/ipset4static_list.conf/' $SYSTEM_FOLDER/etc/AdGuardHome/AdGuardHome.yaml
   $SYSTEM_FOLDER/etc/init.d/S99adguardhome restart
fi

# Remove start folders
rm -r $SCRIPTS

# Remove scripts into folders
rm -f $SYSTEM_FOLDER/etc/init.d/S03ipset-table
rm -f $SYSTEM_FOLDER/etc/ndm/ifstatechanged.d/010-ipset-isp-route.sh
rm -f $SYSTEM_FOLDER/etc/ndm/ifstatechanged.d/011-ipset-vpn1-route.sh
rm -f $SYSTEM_FOLDER/etc/ndm/ifstatechanged.d/012-ipset-vpn2-route.sh
rm -f $SYSTEM_FOLDER/etc/ndm/netfilter.d/010-ipset-isp-netfilter.sh
rm -f $SYSTEM_FOLDER/etc/ndm/netfilter.d/012-ipset-vpn1-netfilter.sh
rm -f $SYSTEM_FOLDER/etc/ndm/netfilter.d/012-ipset-vpn2-netfilter.sh

# Remove ipset conf
rm -f $SYSTEM_FOLDER/etc/ipset4static.conf
rm -f $SYSTEM_FOLDER/etc/ipset4static_list.conf
if [ "$Bird4Static" == "1" ]; then
  cd $HOME_FOLDER && cd ..
  rm -f lists/user-ipset*.list
  rm -f scripts/update-ipset.sh
fi

exit 0
;;
        [Nn]* ) exit 0;;
        * ) echo "Please answer yes or no.";;
    esac
done
