# Select dns
select_dns_mode(){
  echo -e "\nChecking adguardhome or dnsmasq...\n"
  temp_mode=0
  if [ -f "$SYSTEM_FOLDER/etc/init.d/S99adguardhome" ]; then
      if [ $($SYSTEM_FOLDER/etc/init.d/S99adguardhome check | grep -c alive) -eq 1 ]; then temp_mode=1; fi
  fi
  if [ -f "$SYSTEM_FOLDER/etc/init.d/S56dnsmasq" ]; then
      if [ $($SYSTEM_FOLDER/etc/init.d/S56dnsmasq check | grep -c alive) -eq 1 ]; then temp_mode=$(( temp_mode +=2 )); fi
  fi
  if [ "$temp_mode" == "3" ]; then
          echo -e "\nSelect mode: \n 1 - Use adguardhome (default) \n 2 - Use dnsmasq"
          read temp_mode;
          if [ "$temp_mode" != "2" ]; then temp_mode=1; fi
  fi
  if [ "$temp_mode" == "1" ]; then
      MODE="adguardhome"
      echo -e "\nYou use adguardhome mode\n"
  elif [ "$temp_mode" == "2" ]; then
      MODE="dnsmasq"
      echo -e "\nYou use dnsmasq mode\n"
  else
      printf "\nAdGuardHome or dnsmasq was not found.\n"
      printf "No supported DNS backend was found. Install dnsmasq from Entware now? [Y/n] "

      read -r ANSWER

      case "$ANSWER" in
          n|N)
              echo "Installation cancelled."
              exit 0
              ;;
          *)
              install_dnsmasq_func
              MODE="dnsmasq"
              ;;
      esac
  fi
}

install_dnsmasq_func() {

  echo
  echo "Installing dnsmasq..."

  $SYSTEM_FOLDER/bin/opkg update
  echo
  echo "Installing dnsmasq..."

  $SYSTEM_FOLDER/bin/opkg update

  if ! $SYSTEM_FOLDER/bin/opkg install dnsmasq-full; then
      echo
      echo "Failed to install dnsmasq."
      exit 1
  fi

  mkdir -p "$SYSTEM_FOLDER/etc/dnsmasq.d"

  $SYSTEM_FOLDER/bin/opkg update

  select_dns_provider_func

  #
  # Создаем конфиг только если его нет
  #
  if [ ! -f "$SYSTEM_FOLDER/etc/dnsmasq.conf" ]; then

      echo "Creating default dnsmasq configuration..."

      sed \
          -e "s/{{DNS1}}/$DNS1/" \
          -e "s/{{DNS2}}/$DNS2/" \
          "$HOME_FOLDER/Install/common/templates/dnsmasq.conf" \
          > "$SYSTEM_FOLDER/etc/dnsmasq.conf"

  else

      echo "Existing dnsmasq.conf found."
      echo "Keeping current configuration."

  fi

  if [ -f "$SYSTEM_FOLDER/etc/init.d/S56dnsmasq" ]; then
      chmod +x "$SYSTEM_FOLDER/etc/init.d/S56dnsmasq"
      "$SYSTEM_FOLDER/etc/init.d/S56dnsmasq" enable 2>/dev/null
      "$SYSTEM_FOLDER/etc/init.d/S56dnsmasq" start
  fi
  
  sleep 2

  if [ $("$SYSTEM_FOLDER/etc/init.d/S56dnsmasq" check | grep -c alive) -ne 1 ]; then
      echo
      echo "dnsmasq failed to start."
      exit 1
  fi

}

select_dns_provider_func(){

  echo
  echo "Select upstream DNS:"
  echo " 1 - Google (default)"
  echo " 2 - Cloudflare"
  echo " 3 - Quad9"
  echo " 4 - AdGuard DNS"
  echo " 5 - Custom"

  read ANSWER

  case "$ANSWER" in

      2)
          DNS1=1.1.1.1
          DNS2=1.0.0.1
          ;;

      3)
          DNS1=9.9.9.9
          DNS2=149.112.112.112
          ;;

      4)
          DNS1=94.140.14.14
          DNS2=94.140.15.15
          ;;

      5)
          echo "Primary DNS:"
          read -r DNS1

          echo "Secondary DNS:"
          read -r DNS2
          ;;

      *)
          DNS1=8.8.8.8
          DNS2=8.8.4.4
          ;;
  esac
}


# Install packages
install_packages_func(){
  # Update busybox
  $SYSTEM_FOLDER/bin/opkg update
  $SYSTEM_FOLDER/bin/opkg upgrade busybox
  # Installing packages
  $SYSTEM_FOLDER/bin/opkg install ipset iptables diffutils patch
}

# Create start folders
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
    if [ -n "$TTL" ]; then VTTL="$TTL" && echo -e "\nTTL=$TTL\n"; fi
    if [ -n "$ISP_NAME" ]; then VISP_NAME="$ISP_NAME" && echo -e "ISP_NAME=$VISP_NAME\n"; fi
    if [ -n "$ISP_GW" ]; then VISP_GW="$ISP_GW"; fi
    if [ -n "$VPN1_NAME" ]; then VVPN1_NAME="$VPN1_NAME" && echo -e "VPN1_NAME=$VVPN1_NAME\n"; fi
    if [ -n "$VPN2_NAME" ]; then VVPN2_NAME="$VPN2_NAME" && echo -e "VPN2_NAME=$VVPN2_NAME\n"; fi
  fi
}

try_get_bird4static_config_func(){
  echo -e "\nFound bird4static. Do you want use his config? y/n"
  read -r ANSWER
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
    read -r VCONF
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

# Filling script folders and custom sheetsb
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

# Copying the ipset configuration file
copy_ipset4static_config_func(){
  cp $HOME_FOLDER/Install/common/ipset4static.conf $SYSTEM_FOLDER/etc/ipset4static.conf
  sed -i 's/MODEINPUT/'$MODE'/; s/CONFINPUT/'$VCONF'/' $SYSTEM_FOLDER/etc/ipset4static.conf
  if [ -n "$VTTL" ]; then sed -i 's/TTL=.*/TTL='$VTTL'/' $SYSTEM_FOLDER/etc/ipset4static.conf; fi
}

# Show interfaces
show_interfaces_func(){
  echo -e "\n----------------------"
  ip addr show | awk -F" |/" '{gsub(/^ +/,"")}/inet /{print $(NF), $2}'
}

# Config ISP
config_isp_func(){
  if [ -z "$VISP_NAME" ]; then
    echo -e "Enter the name of the provider interface from the list above (for example ppp0 or eth3)\n Or use lo if you dont want this feature"
    read VISP_NAME
  fi
  echo "Your are select ISP $VISP_NAME"
  sed -i 's/ISPINPUT/'$VISP_NAME'/' $SYSTEM_FOLDER/etc/ipset4static.conf
  if [ -n "$VISP_GW" ]; then sed -i 's/#ISP_GW=/ISP_GW=/' $SYSTEM_FOLDER/etc/ipset4static.conf; fi
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
    if ! grep -q "^conf-file=$SYSTEM_FOLDER/etc/ipset4static_list.conf$" \
        "$SYSTEM_FOLDER/etc/dnsmasq.conf"; then
        echo "conf-file=$SYSTEM_FOLDER/etc/ipset4static_list.conf" \
            >> "$SYSTEM_FOLDER/etc/dnsmasq.conf"
    fi
  fi

}

# Starting Services
run_func(){
  $SYSTEM_FOLDER/etc/init.d/S03ipset-table restart
  $SCRIPTS/update-ipset.sh -d
}
