#!/bin/bash
#### Description: Show IPv4, IPv6 and MAC addresses, and many more.
#### Written by : Sotirios Roussis (aka. xtonousou) - xtonousou@gmail.com on 10-2016
#### Limitations: ipinfo.io offers free 1,000 daily requests. (ship -F, -L)

######################## Declarations  #################################

### INFO
AUTHOR="Sotirios Roussis"
AUTHOR_NICKNAME="xtonousou"
GMAIL="${AUTHOR_NICKNAME}@gmail.com"
GITHUB="${HTTPS}github.com/${AUTHOR_NICKNAME}"
VERSION="1.6-dev"

### Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
ORANGE="\033[1;33m"
NORMAL="\e[1;0m"

### Directories, strings and domains
TMP="/tmp/ship"
NULL="/dev/null"
ROOT="${RED}*${NORMAL}"
HTTPS="https://"
IPINFO="ipinfo.io"
GOOGLE="google.com"
GOOGLE_DNS="8.8.8.8"
LOOPBACK="127.0.0.1"

### Dialogs
DIALOG_ALL="┌─┤${GREEN}INTERFACE${NORMAL}├─┬──────┤${GREEN}MAC${NORMAL}├──────┬─┬────┤${GREEN}IPV4${NORMAL}├─────┬─┬────────────────┤${GREEN}IPV6${NORMAL}├─────────────────┐"
DIALOG_ALL_CIDR="┌─┤${GREEN}INTERFACE${NORMAL}├─┬──────┤${GREEN}MAC${NORMAL}├──────┬─┬────┤${GREEN}IPV4${NORMAL}├────────┬─┬──────────────────┤${GREEN}IPV6${NORMAL}├───────────────────┐"
DIALOG_INTERFACES="┌─┤${GREEN}INTERFACE${NORMAL}├─┐"
DIALOG_INTERFACES_MAC="┌─┤${GREEN}INTERFACE${NORMAL}├─┬──────┤${GREEN}MAC${NORMAL}├──────┐"
DIALOG_INTERFACES_GATEWAY="┌─┤${GREEN}INTERFACE${NORMAL}├─┬───┤${GREEN}GATEWAY${NORMAL}├───┐"
DIALOG_INTERFACES_IPV4="┌─┤${GREEN}INTERFACE${NORMAL}├─┬───┤${GREEN}IPV4${NORMAL}├──────┐"
DIALOG_INTERFACES_IPV4_CIDR="┌─┤${GREEN}INTERFACE${NORMAL}├─┬──────┤${GREEN}IPV4${NORMAL}├──────┐"
DIALOG_INTERFACES_IPV6="┌─┤${GREEN}INTERFACE${NORMAL}├─┬─────────────────┤${GREEN}IPV6${NORMAL}├────────────────┐"
DIALOG_INTERFACES_IPV6_CIDR="┌─┤${GREEN}INTERFACE${NORMAL}├─┬───────────────────┤${GREEN}IPV6${NORMAL}├──────────────────┐"
DIALOG_IPV4="┌────┤${GREEN}IPV4${NORMAL}├─────┐"
DIALOG_IPV4_MAC="┌───┤${GREEN}IPV4${NORMAL}├──────┬─┬──────┤${GREEN}MAC${NORMAL}├──────┐"
DIALOG_IPV4_MAC_STATE="┌───┤${GREEN}IPV4${NORMAL}├──────┬─┬──────┤${GREEN}MAC${NORMAL}├──────┬─┬─┤${GREEN}STATE${NORMAL}├──┐"
DIALOG_SPEED="┌─┤${GREEN}INTERFACE${NORMAL}├─┬─┬─┤${GREEN}↓${NORMAL} kB/s├─┬─┬─┤${GREEN}↑${NORMAL} kB/s├──┐"
DIALOG_PORTS="┌────┤${GREEN}PROTOCOL${NORMAL}├──┬──┤${GREEN}TCP/UDP${NORMAL}├──┬┤${GREEN}PORT${NORMAL}├┐"
DIALOG_PRESS_CTRL_C="Press [CTRL+C] to stop"
DIALOG_ERROR="Try ${GREEN}ship -h${NORMAL} or ${GREEN}ship --help${NORMAL} for more information."
DIALOG_ABORTING="${RED}Aborting${NORMAL}."
DIALOG_NO_INTERNET="Internet connection unavailable. ${DIALOG_ABORTING}"
DIALOG_NO_LOCAL_CONNECTION="Local connection unavailable. ${DIALOG_ABORTING}"
DIALOG_SERVER_IS_DOWN="Destination is unreachable. Server may be down or input was invalid. ${DIALOG_ABORTING}"
DIALOG_NOT_A_NUMBER="Option should be integer. ${DIALOG_ABORTING}"

### Arrays
declare -a INTERFACES_ARRAY
INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))

##################### Basic Functions Section  #########################

# Prints active network interfaces with their IPv4 address.
function show_ipv4() {
  
  local IPV4_ARRAY
  
  declare -a IPV4_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
  
	echo -e  "${DIALOG_INTERFACES_IPV4}"
  for i in "${!IPV4_ARRAY[@]}"; do
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address.
function show_ipv6() {
  
  local IPV6_ARRAY
  
  declare -a IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
  
	echo -e  "${DIALOG_INTERFACES_IPV6}"
  for i in "${!IPV6_ARRAY[@]}"; do
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info.
function show_all() {
  
  local IPV4_ARRAY
  local IPV6_ARRAY
  local MAC_OF
  
  declare -a IPV4_ARRAY=($(ip addr show | grep -w inet  | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
  declare -a IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
  
	echo -e  "${DIALOG_ALL}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf " %-14s%-20s%-18s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces and their gateway.
function show_gateway() {
  
  local ONLINE_INTERFACES_ARRAY
  local GATEWAY
  
  declare -a ONLINE_INTERFACES_ARRAY=($(ip route | grep default | awk '{print $5}'))
  
  echo -e  "${DIALOG_INTERFACES_GATEWAY}"
  for i in "${!ONLINE_INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(ip route | grep "${ONLINE_INTERFACES_ARRAY[i]}" | grep ^default | awk '{print $3}')
    printf " %-14s%s\n" "${ONLINE_INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done
  exit
}

# Prints help message.
function usage() {
  
	echo    "usage: ship [option] or [option] {PARAMETER}"
  echo    "  basic operations:"
	echo -e "  ${GREEN}ship -4 ${NORMAL}, ${GREEN}--ipv4 ${NORMAL}          shows active interfaces with their IPv4 address"
	echo -e "  ${GREEN}ship -6 ${NORMAL}, ${GREEN}--ipv6 ${NORMAL}          shows active interfaces with their IPv6 address"
	echo -e "  ${GREEN}ship -a ${NORMAL}, ${GREEN}--all ${NORMAL}           shows all basic info"
	echo -e "  ${GREEN}ship -g ${NORMAL}, ${GREEN}--gateway ${NORMAL}       shows the gateway of online interfaces"
	echo -e "  ${GREEN}ship -h ${NORMAL}, ${GREEN}--help ${NORMAL}          shows this help message"
	echo -e "  ${GREEN}ship -i ${NORMAL}, ${GREEN}--interfaces ${NORMAL}    shows active interfaces"
  echo -e "  ${GREEN}ship -m ${NORMAL}, ${GREEN}--mac ${NORMAL}           shows active interfaces with their MAC address"
  echo -e "  ${GREEN}ship -v ${NORMAL}, ${GREEN}--version ${NORMAL}       shows version of script"
	echo -e "  ${GREEN}ship --cidr-4${NORMAL}, ${GREEN}--cidr-ipv4 ${NORMAL}shows active interfaces with their IPv4 address and CIDR"
	echo -e "  ${GREEN}ship --cidr-6${NORMAL}, ${GREEN}--cidr-ipv6 ${NORMAL}shows active interfaces with their IPv6 address and CIDR"
	echo -e "  ${GREEN}ship --cidr-a${NORMAL}, ${GREEN}--cidr-all ${NORMAL} shows all basic info and CIDR"
	echo
	echo    "  miscellaneous operations:"
  echo -e "  ${GREEN}ship -A ${NORMAL}, ${GREEN}--arp ${NORMAL}           shows neighbor/ARP cache"
  echo -e "  ${GREEN}ship -F ${NORMAL}, ${GREEN}--find ${CYAN}{DOMAIN}${NORMAL}  shows the IP address of a domain"
  echo -e "  ${GREEN}ship -H${NORMAL} , ${GREEN}--hosts ${NORMAL}         shows active hosts on network"
  echo -e " ${ROOT}${GREEN}ship -HM${NORMAL}, ${GREEN}--hosts-mac ${NORMAL}     shows active hosts on network with their MAC address"
  echo -e "  ${GREEN}ship -L ${NORMAL}, ${GREEN}--location ${CYAN}{IP}${NORMAL}  shows location info of an IP address or a domain"
  echo -e " ${ROOT}${GREEN}ship -P ${NORMAL}, ${GREEN}--port ${NORMAL}{PORT}    shows the quantity of connections to {PORT} per IP"
	echo -e "  ${GREEN}ship -S${NORMAL} , ${GREEN}--speed ${NORMAL}         shows in realtime download and upload speed"
	echo -e "  ${GREEN}ship -T${NORMAL} , ${GREEN}--time ${NORMAL}          shows average latency using IPv4"
	echo -e "  ${GREEN}ship -T6${NORMAL}, ${GREEN}--time-ipv6 ${NORMAL}     shows average latency using IPv6"
  echo
  echo -e "If the ${CYAN}{PARAMETER}${NORMAL} is not passed, the action becomes passive."
  echo -e "If the {PARAMETER} is not passed, the action shows some possible options."
  echo -e "The ${ROOT} prefix means that the action requires root privileges."
  exit
}

# Prints active network interfaces.
function show_interfaces() {
  
	echo -e "${DIALOG_INTERFACES}"
  printf  " %s\n" "${INTERFACES_ARRAY[@]}"
  exit
}

# Prints active network interfaces with their MAC address.
function show_mac() {
  
  local MAC_OF
  
	echo -e  "${DIALOG_INTERFACES_MAC}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
  done
  exit
}

# Prints frame by frame an animated ship, and author's info.
function show_version() {
  
  for frame in $(seq 0 4); do
    clear
		print_animated_ship "${frame}"
  done
  exit
}

# Prints active network interfaces with their IPv4 address and CIDR suffix.
function show_ipv4_cidr() {
  
  local IPV4_CIDR_ARRAY
  
  declare -a IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | tail -n +2))
  
	echo -e  "${DIALOG_INTERFACES_IPV4_CIDR}"
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address and CIDR suffix.
function show_ipv6_cidr() {
  
  local IPV6_CIDR_ARRAY
  
  declare -a IPV6_CIDR_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | tail -n +2))
  
	echo -e  "${DIALOG_INTERFACES_IPV6_CIDR}"
  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info and CIDR suffix.
function show_all_cidr() {
  
  local IPV4_CIDR_ARRAY
  local IPV6_CIDR_ARRAY
  local MAC_OF
  
  IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet  | awk '{print $2}' | tail -n +2))
  IPV6_CIDR_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | tail -n +2))
  
	echo -e "${DIALOG_ALL_CIDR}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf " %-14s%-20s%-21s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}

################## Miscellaneous Functions Section  ####################

# Shows arp cache table.
function show_arp_cache() {
  
  local FILENAME
  
  FILENAME="ARP_CACHE"
  check_directory_or_touch_file "${FILENAME}"
  
  ip neigh | egrep -i 'permanent|noarp|stale|reachable|incomplete|delay|probe' | \
  awk '{printf (" %-18s%-20s%s\n", $1, $5, $6)}' | sort -V  >> "${TMP}/${FILENAME}"
  echo -e "${DIALOG_IPV4_MAC_STATE}"
  cat < "${TMP}/${FILENAME}" | sort -V
  mr_proper
}

# Prints the public IP address of a website or server. If $1 is empty prints user's public IP, if not, $1 should be example.com.
function show_ip_from() {
  
  local HTTP_CODE_IPINFO
  local FILENAME
  local COUNTER
  local IP
  
  if [[ -z "$1" ]]; then
    HTTP_CODE_IPINFO=$(wget --spider -S "${IPINFO}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    if [[ "${HTTP_CODE_IPINFO}" -eq "200" ]]; then
      IP=$(wget "${IPINFO}/ip" -qO -)
		  echo "${IP}"
      exit
	  else
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  else
    HTTP_CODE_IPINFO=$(wget --spider -S "$1" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    if [[ "${HTTP_CODE_IPINFO}" -eq "200" ]]; then
      FILENAME="IPS_FROM"
      check_directory_or_touch_file "${FILENAME}"
      INPUT=$(echo "$1" | sed 's/^http\(\|s\):\/\///g')
      COUNTER=0
      while [[ "${COUNTER}" -lt "20" ]]; do
        ping -c 1 -i 0.2 -w 5 "${INPUT}" 2>"${NULL}" | awk -F '[()]' '/PING/{print $2}' >> "${TMP}/${FILENAME}" &
        let COUNTER=COUNTER+1
      done
      take_your_time
      cat < "${TMP}/${FILENAME}" | sort -V | uniq -u
      mr_proper
    else
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  fi
}

# Prints various location info of a domain. If $1 is empty prints user's location info, if not, $1 should be example.com.
function show_location_info() {
  
  local HTTP_CODE_IPINFO
  local INPUT
  local MAP_LOC
  local ZOOM
  
  # ipinfo.io requires
  local IP
  local HOSTNAME
  local CITY
  local REGION
  local COUNTRY
  local LOC
  local ORG  
  
  HTTP_CODE_IPINFO=$(wget --spider -S "${IPINFO}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  
  if [[ ! "${HTTP_CODE_IPINFO}" -eq "200" ]]; then
    error_exit "${DIALOG_SERVER_IS_DOWN}"
  else
    if [[ ! -z "$1" ]]; then
      INPUT=$(echo "$1" | sed 's/^http\(\|s\):\/\///g')
      IP=$(ping -c 1 -w 5 "${INPUT}" 2>"${NULL}" | awk -F'[()]' '/PING/{print $2}' &)
      ZOOM="9"
      HOSTNAME=$(wget -qO - ${IPINFO}/"${IP}"/hostname &)
      CITY=$(wget -qO - ${IPINFO}/"${IP}"/city &)
      REGION=$(wget -qO - ${IPINFO}/"${IP}"/region &)
      COUNTRY=$(wget -qO - ${IPINFO}/"${IP}"/country &)
      LOC=$(wget -qO - ${IPINFO}/"${IP}"/loc &)
      ORG=$(wget -qO - ${IPINFO}/"${IP}"/org &)
      # pass data one by one to print_location_info()
      print_location_info "${IP}" "${HOSTNAME}" "${CITY}" "${REGION}" "${COUNTRY}" "${LOC}" "${ORG}"
      MAP_LOC="${HTTPS}maps.googleapis.com/maps/api/staticmap?center=${LOC}&zoom=${ZOOM}&size=640x640&sensor=false"
      echo
      echo -e "${MAP_LOC}"
      exit
    else
      ZOOM="12"
      IP=$(wget -qO - ${IPINFO}/ip &)
      HOSTNAME=$(wget -qO - ${IPINFO}/"${IP}"/hostname &)
      CITY=$(wget -qO - ${IPINFO}/"${IP}"/city &)
      REGION=$(wget -qO - ${IPINFO}/"${IP}"/region &)
      COUNTRY=$(wget -qO - ${IPINFO}/"${IP}"/country &)
      LOC=$(wget -qO - ${IPINFO}/"${IP}"/loc &)
      ORG=$(wget -qO - ${IPINFO}/"${IP}"/org &)
      # pass data one by one to print_location_info()
      print_location_info "${IP}" "${HOSTNAME}" "${CITY}" "${REGION}" "${COUNTRY}" "${LOC}" "${ORG}"
      MAP_LOC="${HTTPS}maps.googleapis.com/maps/api/staticmap?center=${LOC}&zoom=${ZOOM}&size=640x640&sensor=false"
      echo
      echo -e "${MAP_LOC}"
      exit
    fi
  fi
}

# Prints connections and the count of them per IP.
function show_port_connections() {
  
  if [[ -z "$1" ]]; then
    print_port_protocol_list
    exit
  fi
  
  check_root_user
  check_for_missing_parameter "-P" "--port" "$1"
  check_if_parameter_is_not_numerical "$1"
  
  local PORT
  
  PORT="$1"
  
  clear
  while true; do
    clear
    echo -e "${DIALOG_PRESS_CTRL_C}"
    echo
    echo -e "      ${GREEN}┌─> ${RED}Count Port ${GREEN}<─┐"
    echo -e "      │ ┌───────> ${RED}IPv4 ${GREEN}└─> ${RED}${PORT}"
    echo -e "    ${GREEN}┌─┘ └──────────────┐${NORMAL}"
    ss -np | grep ":${PORT}" | awk '{print $6}' | cut -d : -f 1 | uniq -c
    sleep 3
  done
}

# Prints in realtime download and upload speed
function show_speed() {
  
  local ONLINE_INTERFACE
  local R1
  local T1
  local R2
  local T2
  local TBPS
  local RBPS
  local TKBPS
  local RKBPS
  
  ONLINE_INTERFACE=$(ip route get "${GOOGLE_DNS}" | awk -F "dev " 'NR == 1 { split($2, a, " "); print a[1] }')
  
  while true; do
    clear
    echo -e "${DIALOG_PRESS_CTRL_C}"
    echo
    echo -e "${DIALOG_SPEED}"
    printf " %-16s%-13s%s\n" "${ONLINE_INTERFACE}" "${RKBPS}" "${TKBPS}"
    R1=$(cat /sys/class/net/"${ONLINE_INTERFACE}"/statistics/rx_bytes)
    T1=$(cat /sys/class/net/"${ONLINE_INTERFACE}"/statistics/tx_bytes)
    sleep 1
    R2=$(cat /sys/class/net/"${ONLINE_INTERFACE}"/statistics/rx_bytes)
    T2=$(cat /sys/class/net/"${ONLINE_INTERFACE}"/statistics/tx_bytes)
    TBPS=$((T2 - T1))
    RBPS=$((R2 - R1))
    TKBPS=$(echo "scale=2; $TBPS / 1024" | bc)
    RKBPS=$(echo "scale=2; $RBPS / 1024" | bc)
  done
}

# Prints average rtt from google.com after six pings. IPv4 or IPv6.
function show_avg_ping() {

	local HTTP_CODE_GOOGLE
  local PING_4
  local HAS_IPV6
  local PING_6
  
  HTTP_CODE_GOOGLE=$(wget --spider -S "${GOOGLE}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
 
  if [[ "${HTTP_CODE_GOOGLE}" -eq "200" ]]; then
    case "$1" in
      "--ipv4")
        echo    "Playing ping pong with Google, please wait..."
        PING_4=$(ping -i 0.5 -c 10 ${GOOGLE} | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
		    echo -e "Average response time: ${GREEN}${PING_4} ms${NORMAL}"
        exit
      ;;
      "--ipv6")
        HAS_IPV6=$(lsmod | awk '{print $1}' | grep -o ipv6)
        if [[ "${HAS_IPV6}" ]]; then
          echo    "Playing ping pong with Google, please wait..."
          PING_6=$(ping -6 -i 0.5 -c 10 "${GOOGLE}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
		      echo -e "Average response time: ${GREEN}${PING_6} ms${NORMAL}"
          exit
        else
          error_exit "IPv6 unavailable. ${DIALOG_ABORTING}"
        fi
      ;;
    esac
	else
		error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
}

# Scans live hosts on network and prints their IPv4 address with or without MAC address. ICMP and ARP.
function show_live_hosts() {
  
  local ONLINE_INTERFACE
  local NETWORK_IP
  local FILTERED_IP
  local FILENAME
  local FILENAME_TWO
  
  ONLINE_INTERFACE=$(ip route get "${GOOGLE_DNS}" | awk -F "dev " 'NR == 1 { split($2, a, " "); print a[1] }')
  NETWORK_IP=$(ip route | grep "${ONLINE_INTERFACE}" | grep src | awk '{print $1}' | cut -f 1 -d "/")
  FILTERED_IP=$(echo "${NETWORK_IP}" | awk 'BEGIN{FS=OFS="."} NF--')
  
  case "$1" in
    "--normal")
      FILENAME="IPV4_OF_PING"
      check_directory_or_touch_file "${FILENAME}"
      for i in {1..254}; do
        ping "${FILTERED_IP}.${i}" -c 1 -w 5 >"${NULL}" &&
        echo " ${FILTERED_IP}.${i}" >> "${TMP}/${FILENAME}" &
        sleep 0.012
      done
      take_your_time
      echo -e "${DIALOG_IPV4}"
      cat < "${TMP}/${FILENAME}" | sort -V | uniq -u
      mr_proper
      exit
    ;;
    "--mac")
      FILENAME="IPS_OF_ARPING"
      FILENAME_TWO="MACS_OF_ARPING"
      check_directory_or_touch_file "${FILENAME}"
      check_directory_or_touch_file "${FILENAME_TWO}"
      check_root_user
      for i in {1..254}; do
        arping -I "${ONLINE_INTERFACE}" "${FILTERED_IP}.${i}" -c 1 2>"${NULL}" | tail -n +2 | head -n 1 | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' >> "${TMP}/${FILENAME}" &
        sleep 0.012
        arping -I "${ONLINE_INTERFACE}" "${FILTERED_IP}.${i}" -c 1 2>"${NULL}" | tail -n +2 | head -n 1 | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}'  >> "${TMP}/${FILENAME_TWO}" &
      done
      take_your_time
      sed -i 's/^/ /' "${TMP}/${FILENAME}"
      echo -e "${DIALOG_IPV4_MAC}"
      pr -mtw 37 "${TMP}/${FILENAME}" "${TMP}/${FILENAME_TWO}"
      mr_proper
      exit
    ;;
  esac
}

################ In-function functions section ^-^ #####################
###################### Printing functions ##############################

# Animation parts used in show_version().
function print_animated_ship() {
  
  local MAST
  local DECK_DOWN
  local DECK_LEFT
  local DECK_RIGHT
  
  MAST="${ORANGE}!${NORMAL}"
  DECK_DOWN="${ORANGE}_${NORMAL}"
  DECK_LEFT="${ORANGE}\\\\${NORMAL}"
  DECK_RIGHT="${ORANGE}/${NORMAL}"
  
	case "$1" in
		"0")
			echo
			echo    "     _~"
			echo -e "  _~ )_)_~              Author .: ${GREEN}${AUTHOR}${NORMAL}"
			echo -e "  )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "  ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "  ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}             Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
    ;;
		"1")
			echo
			echo    "      _~"
			echo -e "   _~ )_)_~             Author .: ${GREEN}${AUTHOR}${NORMAL}"
			echo -e "   )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "   ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "   ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}            Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"2")
			echo
			echo    "       _~"
			echo -e "    _~ )_)_~            Author .: ${GREEN}${AUTHOR}${NORMAL}"
			echo -e "    )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "    ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "    ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}           Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"3")
			echo
			echo    "        _~"
			echo -e "     _~ )_)_~           Author .: ${GREEN}${AUTHOR}${NORMAL}"
			echo -e "     )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "     ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "     ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}          Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"4")
			echo
			echo    "         _~"
			echo -e "      _~ )_)_~          Author .: ${GREEN}${AUTHOR}${NORMAL}"
			echo -e "      )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "      ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "      ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}         Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
	esac
	sleep .25
}

# Prints show_location_info() data.
function print_location_info() {
  
  echo -e "${GREEN}IP${RED}\t\t$1"
  echo -e "${GREEN}Hostname${NORMAL}\t$2"
  echo -e "${GREEN}City${NORMAL}\t\t$3"
  echo -e "${GREEN}Region${NORMAL}\t\t$4"
  echo -e "${GREEN}Country${NORMAL}\t\t$5"
  echo -e "${GREEN}Location${RED}\t$6"
  echo -e "${GREEN}Organization${NORMAL}\t$7"
}

# Prints a list of most common ports with protocols.
function print_port_protocol_list() {

  local PORTS_ARRAY
  local PORTS_TCP_UDP_ARRAY
  local PORTS_PROTOCOL_ARRAY

  declare -a PORTS_ARRAY=("20-21" "22" "23" "25" "53" "67-68" "69" "80"\
                          "110" "123" "137-139" "143" "161-162" "179"\
                          "389" "443" "636" "989-990")
  declare -a PORTS_TCP_UDP_ARRAY=("TCP" "TCP" "TCP" "TCP" "TCP/UDP"\
                                  "UDP" "UDP" "TCP" "TCP" "UDP"\
                                  "TCP/UDP" "TCP" "TCP/UDP" "TCP"\
                                  "TCP/UDP" "TCP" "TCP/UDP" "TCP")
  declare -a PORTS_PROTOCOL_ARRAY=("FTP" "SSH" "Telnet" "SMTP" "DNS"\
                                   "DHCP" "TFTP" "HTTP" "POPv3" "NTP"\
                                   "NetBIOS" "IMAP" "SNMP" "BGP" "LDAP"\
                                   "HTTPS" "LDAPS" "FTP over TLS/SSL")
  
  echo -e  "${DIALOG_PORTS}"
  for i in "${!PORTS_ARRAY[@]}"; do
    printf " %-20s%-11s%s\n" "${PORTS_PROTOCOL_ARRAY[i]}" "${PORTS_TCP_UDP_ARRAY[i]}" "${PORTS_ARRAY[i]}"
  done
  exit
}

################### Checking n' Cleaning functions #####################

# Checks network connection (local or internet).
function check_connectivity() {
  
  local GATEWAY
  
  case "$1" in
    "--local")
      GATEWAY=$(ip route | grep ^default)
      if [[ ! "${GATEWAY}" ]]; then
        error_exit "${DIALOG_NO_LOCAL_CONNECTION}"
      fi
    ;;
    "--internet")
      wget -q --spider "${GOOGLE}"
      if [[ ! "$?" -eq "0" ]]; then
        error_exit "${DIALOG_NO_INTERNET}"
      fi
    ;;
  esac
}

# CURRENTLY NOT USED. Checks tool's existance in system.
function check_for_missing_tool() {
  
  hash "$1" 2>"${NULL}" || {
    error_exit "Install ${ORANGE}$1${NORMAL} and then try again. ${DIALOG_ABORTING}"
  }
}

# e.g.(-f example.com). Checks if "example.com" is empty. $1 is the option, $2 is the alternative option and $3 is the parameter.
function check_for_missing_parameter() {
  
  if [[ -z "$3" ]]; then
    echo -e "Option ${GREEN}ship $1 ${NORMAL}or ${GREEN}ship $2 ${NORMAL}requires {PARAMETER},"
    error_exit "e.g. ${GREEN}ship $1 ${NORMAL}{PARAMETER} or ${GREEN}ship $2 ${NORMAL}{PARAMETER}."
  fi
}

# Verifies parameter to be number.
function check_if_parameter_is_not_numerical() {
  
  case "$1" in
    ''|*[!0-9]*) error_exit "${DIALOG_NOT_A_NUMBER}" "$1";;
  esac
}

# Checks if /tmp/ship exists, if not creates the dir and touches a file given by user.
function check_directory_or_touch_file() {
  
  if [[ ! -d "${TMP}" ]]; then
      mkdir "${TMP}"
      if [[ ! -z "$1" ]]; then
        touch "${TMP}/$1" 2>"${NULL}"
      fi
  fi
}

# Checks for root privileges.
function check_root_user() {
  
  if [[ "$(id -u)" -ne "0" ]]; then
    error_exit "${GREEN}ship${NORMAL} requires ${RED}root${NORMAL} privileges for this action."
  fi
}

# Deletes every file that is created by this script. Usually in /tmp
function mr_proper() {
  
  rm -rf "${TMP}"
}

####################### Error handling functions #######################

# Used with zero parameters: exit 1.
# Used with one parameter  : echoes parameter, usually error dialogs.
# Used with two parameters : invalid option, then echoes first parameter, usually error dialogs.
function error_exit() {
  
  if [[ -z "$1" ]]; then
    exit 1
  elif [[ -z "$2" ]]; then
    echo -e  "$1"
    exit 1
  else
    echo -e  "${GREEN}ship${NORMAL}: invalid option -- '$2'"
    echo -e  "$1"
    exit 1
  fi
}

# Checks how many cores does the system has. Sleeping time depends on number of CPU cores.
function take_your_time() {
  
  local NUMBER_OF_CORES
  
  NUMBER_OF_CORES=$(grep -c "^processor" /proc/cpuinfo)
  
  case "${NUMBER_OF_CORES}" in
    "8")  sleep 1   ;;
    "4")  sleep 1.2 ;;
    "2")  sleep 1.5 ;;
    "1")  sleep 1.8 ;;
    *)    sleep .5  ;;
  esac
  
}

###################### Initializes script. #############################
function __init__() {
  
  if [[ -z "$1" ]]; then error_exit "${DIALOG_ERROR}"; fi
  
  check_directory_or_touch_file
  
  while :
  do
    case "$1" in
      "-4"|"--ipv4") show_ipv4; break ;;
      "-6"|"--ipv6") show_ipv6; break ;;
      "-A"|"--arp") show_arp_cache; break ;;
      "-a"|"--all") show_all; break ;;
      "-F"|"--find") check_connectivity "--internet"; show_ip_from "$2"; shift 2; break ;;
      "-g"|"--gateway") check_connectivity "--local"; show_gateway; break ;;
      "-H"|"--hosts") check_connectivity "--local"; show_live_hosts --normal; break ;;
      "-HM"|"--hosts-mac") check_connectivity "--local"; show_live_hosts --mac; break ;;
      "-h"|"--help") usage; break ;;
      "-i"|"--interfaces") show_interfaces; break ;;
      "-L"|"--location") check_connectivity "--internet"; show_location_info "$2"; shift 2; break ;;
      "-P"|"--port") check_connectivity "--internet"; show_port_connections "$2"; shift 2; break ;;
      "-m"|"--mac") show_mac; break ;;
      "-T"|"--time") check_connectivity "--internet"; show_avg_ping --ipv4; break ;;
      "-T6"|"--time-ipv6") check_connectivity "--internet"; show_avg_ping --ipv6; break ;;
      "-S"|"--speed") check_connectivity "--internet"; show_speed; break ;;
      "-v"|"--version") show_version; break ;;
      "--cidr-4"|"--cidr-ipv4") show_ipv4_cidr; break ;;
      "--cidr-6"|"--cidr-ipv6") show_ipv6_cidr; break ;;
      "--cidr-a"|"--cidr-all") show_all_cidr; break ;;
      *) error_exit "${DIALOG_ERROR}" "$1"; break ;;
    esac
  done
}

__init__ "$1" "$2"
