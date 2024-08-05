 #SCRIPT VARIABLE
SYSTEM_FOLDER=SYSTEMFOLDERINPUT
IPSET_USER_VPN=$SYSTEM_FOLDER/etc/ipset-vpn.list
IPSET_CONF=$SYSTEM_FOLDER/etc/ipset4static.conf
IPSET_LIST=$SYSTEM_FOLDER/etc/ipset4static_list.conf
VPNTXT=$HOMEPATH/lists/user-ipset-vpn.list
VPN1TXT=$HOMEPATH/lists/user-ipset-vpn1.list
VPN2TXT=$HOMEPATH/lists/user-ipset-vpn2.list
MD5_SUM=$HOMEPATH/scripts/sum.md5

 #INFO VARIABLE
source $IPSET_CONF
VERSION=VERSIONINPUT

 #GET INFO
get_info_func() {
  if [[ "$1" == "-v" ]]; then
    echo "VERSION=$VERSION"
    echo "CONF=$CONF"
    if [ $VCONF == "1" ]; then echo -e " Use one vpn\n ISP=$VISP VPN=$VVPN1"; else echo -e " Use double vpn\n ISP=$VISP VPN1=$VVPN1 VPN2=$VVPN2"; fi
    echo "MODE=$VMODE"
    if [ $VMODE == "1" ]; then echo -e " Download mode\n URLS=$VURLS";
    elif [ $VMODE == 2 ]; then echo -e " BGP mode\n IP=$VBGP_IP AS=$VBGP_AS";
    else echo " File mode"
    fi
    exit
  elif [[ "$1" == "-d" ]]; then DEBUG=1; fi
}

 #INIT FILES FUNCTION
init_files_func() {
  if [[ "$DEBUG" == 1 ]]; then echo -e "\n########### $(date) STEP_2: add init files ###########\n" >&2; fi
  for file in $@; do if [ ! -f $file ]; then touch $file; fi; done
  if [[ "$INIT" == "-i" ]]; then exit; fi
}

vpn_variable_generate() {
  VPN_COMMON=$(cat $VPNTXT | sed '/^#/d')
  if [ "$CONF" == "2" ]; then
    VPN_VPN1=$(cat $VPN1TXT | sed '/^#/d')
    VPN_VPN2=$(cat $VPN2TXT | sed '/^#/d')
  fi
}

adguard_config_generate(){
  if [ "$CONF" == "1" ]; then
    echo -e "$(echo $VPN_COMMON | sed 's/ /,/g')/ipset_vpn1"
  elif [ "$CONF" == "2" ]; then
    echo -e "$(echo $VPN_COMMON | sed 's/ /,/g')/ipset_vpn1,ipset_vpn2"
    echo -e "$(echo $VPN_VPN1 | sed 's/ /,/g')/ipset_vpn1"
    echo -e "$(echo $VPN_VPN2 | sed 's/ /,/g')/ipset_vpn2"
  fi
}
dnsmasq_config_generate(){
  if [ "$CONF" == "1" ]; then
    echo -e "ipset=$(echo $VPN_COMMON | sed 's/ /\//g')/ipset_vpn1"
  elif [ "$CONF" == "2" ]; then
    echo -e "ipset=$(echo $VPN_COMMON | sed 's/ /\//g')/ipset_vpn1,ipset_vpn2"
    echo -e "ipset=$(echo $VPN_VPN1 | sed 's/ /\//g')/ipset_vpn1"
    echo -e "ipset=$(echo $VPN_VPN2 | sed 's/ /\//g')/ipset_vpn2"
  fi
}

ipset_func() {
  vpn_variable_generate
  if [ "$MODE" == "adguardhome" ]; then
    adguard_config_generate
  elif [ "$MODE" == "dnsmasq" ]; then
    dnsmasq_config_generate
  fi
}

 #DIFF FUNCTION
diff_funk() {
  if [ "$DEBUG" == "1" ]; then
    patch_file=/tmp/patch_$(echo $1 | awk -F/ '{print $NF}')
    echo -e "\n########### $(date) STEP_3: diff $(echo $1 | awk -F/ '{print $NF}' ) ###########\n" >&2
    diff -u $1 $2 > $patch_file
    cat $patch_file && patch $1 $patch_file
    rm $patch_file
  else
    diff -u $1 $2 | patch $1 -
  fi
}

 #RESTART DNS FUNCTION
restart_dns_func() {
  if [ "$DEBUG" == "1" ]; then echo -e "\n########### $(date) STEP_5: restart dns ###########\n" >&2; fi
  if [ "$(cat $MD5_SUM)" != "$(md5sum $IPSET_LIST*)" ]; then
    md5sum $IPSET_LIST > $MD5_SUM
    echo "Restarting DNS"
    if [ "$MODE" == "adguardhome" ]; then
      $SYSTEM_FOLDER/etc/init.d/S99adguardhome restart
    elif [ "$MODE" == "dnsmasq" ]; then
      $SYSTEM_FOLDER/etc/init.d/S56dnsmasq restart
    fi
  fi
}