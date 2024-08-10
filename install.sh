#!/bin/sh

VERSION_NEW="v1.0.2"

# Getting the path to run the script
ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"` && HOME_FOLDER_SED=$(echo $HOME_FOLDER | sed 's/\//\\\//g')
LISTS=$HOME_FOLDER/lists
SCRIPTS=$HOME_FOLDER/scripts && SCRIPTS_SED=$(echo $SCRIPTS | sed 's/\//\\\//g')
SYSTEM_FOLDER=`echo $HOME_FOLDER | awk -F/opt '{print $1}'`
SYSTEM_FOLDER=$SYSTEM_FOLDER/opt && SYSTEM_FOLDER_SED=$(echo $SYSTEM_FOLDER | sed 's/\//\\\//g')
echo -e "HomeFolder is $HOME_FOLDER \nSystemFolder is $SYSTEM_FOLDER"

echo -e "\nChecking adguardhome or dnsmasq...\n"
if [ -f "$SYSTEM_FOLDER/etc/init.d/S99adguardhome" ]; then
    if [ $($SYSTEM_FOLDER/etc/init.d/S99adguardhome check | grep -c alive) -eq 1 ]; then 
        MODE="adguardhome"
        echo -e "\nYou use adguardhome mode\n"
    fi
elif [ -f "$SYSTEM_FOLDER/etc/init.d/S56dnsmasq" ]; then
    if [ $($SYSTEM_FOLDER/etc/init.d/S56dnsmasq check | grep -c alive) -eq 1 ]; then
        MODE="dnsmasq"
        echo -e "\nYou use dnsmasq mode\n"
    fi
else
    echo -e "\nadguardhome or dnsmasq dont running!\nPlease install and configure one of them first!!!\n"
    exit 0
fi


while true; do
    echo -e "\nBegin install? y/n"
    read yn
    case $yn in
        [Yy]* )

if [ $(echo $ABSOLUTE_FILENAME | grep -c Bird4Static) -eq 1 ]; then Bird4Static=1; else Bird4Static=0; fi

source $HOME_FOLDER/Install/install_func.sh

# Installing packages
install_packages_func

# Create start folders
create_folder_func

# Stop service if exist
stop_func

# Try get old config
if [ "$1" == "-u" ]; then UPDATE=1 && get_old_config_func; fi

# try get bird4static config
if [ "$Bird4Static" == "1" ]; then try_get_bird4static_config_func; fi

# Select number vpn
select_number_vpn_func

# Filling script folders and custom sheets
fill_folder_and_sed_func

# Copying the ipset4static configuration file
copy_ipset4static_config_func

# Reading vpn and provider interfaces, replacing in scripts and bird configuration
show_interfaces_func
config_isp_func
config_vpn1_func
if [ "$VCONF" == "2" ]; then config_vpn2_func; fi

# Organizing scripts into folders
ln_scripts_func

# Change dns settings to ipset file
change_dns_config

# Starting Services
run_func

exit 0
;;
        [Nn]* ) exit 0;;
        * ) echo "Please answer yes or no.";;
    esac
done