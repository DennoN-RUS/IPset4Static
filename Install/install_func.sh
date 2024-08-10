#+ Install packages
install_packages_func(){
  # Update busybox
  $SYSTEM_FOLDER/bin/opkg update
  $SYSTEM_FOLDER/bin/opkg upgrade busybox
  # Installing packages
  $SYSTEM_FOLDER/bin/opkg install ipset iptables diffutils patch
}

#+ Create start folders
create_folder_func(){
  mkdir -p $SCRIPTS
  mkdir -p $LISTS
}

# Stop service if exist
stop_func(){
  # Stop table service
  if [ -f "$SYSTEM_FOLDER/etc/init.d/S03ipset-table" ]; then
    echo "Stop ipset-table"
    $SYSTEM_FOLDER/etc/init.d/S03ipset-table stop
  fi
}

# Try get old config
get_old_config_func(){
  echo -e "\n Try to load old config"
  if [ -f "$SYSTEM_FOLDER/etc/ipset4static.conf" ]; then
    source $SYSTEM_FOLDER/etc/ipset4static.conf
    if [ -n "$CONF" ]; then VCONF="$CONF" && echo -e "\nCONF=$VCONF\n"; fi
    if [ -n "$ISP_NAME" ]; then VISP_NAME="$ISP_NAME" && echo -e "ISP_NAME=$VISP_NAME\n"; fi
    if [ -n "$VPN1_NAME" ]; then VVPN1_NAME="$VPN1_NAME" && echo -e "VPN1_NAME=$VVPN1_NAME\n"; fi
    if [ -n "$VPN2_NAME" ]; then VVPN2_NAME="$VPN2_NAME" && echo -e "VPN2_NAME=$VVPN2_NAME\n"; fi
  fi
}

try_get_bird4static_config_func(){
  echo -e "\nFound bird4static. Do you want use his config? y/n"
  read ANSWER
  if [ "$ANSWER" == "y" ]; then
    cd $HOME_FOLDER && cd ..
    if [ -f "scripts/func.sh" ]; then
      source scripts/func.sh
      if [ -n "$VISP" ]; then VISP_NAME="$VISP" && echo -e "ISP_NAME=$VISP_NAME"; fi
      if [ -n "$VVPN1" ]; then VVPN1_NAME="$VVPN1" && echo -e "VPN1_NAME=$VVPN1_NAME"; fi
      if [ -n "$VVPN2" ]; then VVPN2_NAME="$VVPN2" && echo -e "VPN2_NAME=$VVPN2_NAME"; fi
    fi
  fi
}

# Select number vpn
select_number_vpn_func(){
  if [ -z "$VCONF" ]; then
    echo -e "\nDo you want to use double vpn configuration? 1 - no (default) 2 - yes"
    read VCONF
  fi
  if [ "$VCONF" != "2" ]; then 
    VCONF=1
    CONFFOLDER="one_vpn"
    echo "You are select install for one vpn"
  else 
    CONFFOLDER="double_vpn"
    echo "You are select install for double vpn"
  fi
}

# Filling script folders and custom sheets
fill_folder_and_sed_func(){
  cp $HOME_FOLDER/Install/common/*.sh $SCRIPTS
  cp $HOME_FOLDER/Install/$CONFFOLDER/*.sh $SCRIPTS
  chmod +x $SCRIPTS/*.sh
  if [ "$UPDATE" != "1" ]; then
    cp -i $HOME_FOLDER/Install/common/*.list $LISTS
    if [ "$VCONF" == "2" ]; then cp -i $HOME_FOLDER/Install/$CONFFOLDER/*.list $LISTS; fi
  fi
  sed -i 's/VERSIONINPUT/'$VERSION_NEW'/; s/SYSTEMFOLDERINPUT/'$SYSTEM_FOLDER_SED'/; s/HOMEFOLDERINPUT/'$HOME_FOLDER_SED'/' $SCRIPTS/*.sh
  rm -f $SCRIPTS/sum.md5
}

# Copying the bird configuration file
copy_ipset4static_config_func(){
  cp $HOME_FOLDER/Install/common/ipset4static.conf $SYSTEM_FOLDER/etc/ipset4static.conf
  sed -i 's/MODEINPUT/'$MODE'/; s/CONFINPUT/'$VCONF'/' $SYSTEM_FOLDER/etc/ipset4static.conf
}

# Show interfaces
show_interfaces_func(){
  echo -e "\n----------------------"
  ip addr show | awk -F" |/" '{gsub(/^ +/,"")}/inet /{print $(NF), $2}'
}

# Config ISP
config_isp_func(){
  if [ -z "$VISP_NAME" ]; then
    echo "Enter the name of the provider interface from the list above (for example ppp0 or eth3)"
    read VISP_NAME
  fi
  echo "Your are select ISP $VISP_NAME"
  sed -i 's/ISPINPUT/'$VISP_NAME'/' $SYSTEM_FOLDER/etc/ipset4static.conf
}

# Config VPN1
config_vpn1_func(){
  if [ -z "$VVPN1_NAME" ]; then
    echo "Enter the VPN interface name from the list above (for example ovpn_br0 or nwg0)"
    read VVPN1_NAME
  fi
  echo "Your are select VPN1 $VVPN1_NAME"
  sed -i 's/VPN1INPUT/'$VVPN1_NAME'/' $SYSTEM_FOLDER/etc/ipset4static.conf
}

# Config VPN2
config_vpn2_func(){
  if [ -z "$VVPN2_NAME" ]; then
    echo "Enter the Second VPN interface name from the list above (for example ovpn_br0 or nwg0)"
    read VVPN2_NAME
  fi
  echo "Your are select VPN2 $VVPN2_NAME"
  sed -i 's/VPN2INPUT/'$VVPN2_NAME'/' $SYSTEM_FOLDER/etc/ipset4static.conf
}

# Organizing scripts into folders
ln_scripts_func(){
  ln -sf $SCRIPTS/ipset-table.sh $SYSTEM_FOLDER/etc/init.d/S03ipset-table
  ln -sf $SCRIPTS/ipset-isp-route.sh $SYSTEM_FOLDER/etc/ndm/ifstatechanged.d/012-ipset-isp-route.sh
  ln -sf $SCRIPTS/ipset-vpn1-route.sh $SYSTEM_FOLDER/etc/ndm/ifstatechanged.d/011-ipset-vpn1-route.sh
  ln -sf $SCRIPTS/ipset-isp-netfilter.sh $SYSTEM_FOLDER/etc/ndm/netfilter.d/012-ipset-isp-netfilter.sh
  ln -sf $SCRIPTS/ipset-vpn1-netfilter.sh $SYSTEM_FOLDER/etc/ndm/netfilter.d/011-ipset-vpn1-netfilter.sh
  if [ "$VCONF" == 2 ]; then
    ln -sf $SCRIPTS/ipset-vpn2-route.sh $SYSTEM_FOLDER/etc/ndm/ifstatechanged.d/010-ipset-vpn2-route.sh
    ln -sf $SCRIPTS/ipset-vpn2-netfilter.sh $SYSTEM_FOLDER/etc/ndm/netfilter.d/010-ipset-vpn2-netfilter.sh
  fi
  if [ "$Bird4Static" == "1" ]; then
    cd $HOME_FOLDER && cd ..
    ln -sf $LISTS/*.list lists/
    ln -sf $SCRIPTS/update-ipset.sh scripts/
  fi
}

change_dns_config(){
  if [ "$MODE" == "adguardhome" ]; then
    sed -i 's/ipset_file.*/ipset_file: '$SYSTEM_FOLDER_SED'\/etc\/ipset4static_list.conf/' $SYSTEM_FOLDER/etc/AdGuardHome/AdGuardHome.yaml
  elif [ "$MODE" == "dnsmasq" ]; then
    if [ $(cat $SYSTEM_FOLDER/etc/dnsmasq.conf | grep conf-file=$SYSTEM_FOLDER/etc/ipset4static_list.conf -c ) -eq 0 ]; then
      echo conf-file=$SYSTEM_FOLDER/etc/ipset4static_list.conf >> $SYSTEM_FOLDER/etc/dnsmasq.conf
    fi
  fi

}

# Starting Services
run_func(){
  $SYSTEM_FOLDER/etc/init.d/S03ipset-table restart
  $SCRIPTS/update-ipset.sh -d
}
