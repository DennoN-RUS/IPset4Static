#!/bin/sh

 #SCRIPT VARIABE
HOMEPATH=HOMEFOLDERINPUT

source $HOMEPATH/scripts/func.sh

 #GET INFO ABOUT SCRIPT
get_info_func $1

 #INIT FILES
WORK_FILES="$IPSET_LIST $MD5_SUM"
INIT=$1

init_files_func $WORK_FILES

ipset_func | diff_funk $IPSET_LIST -

 #RESTART DNS
restart_dns_func
