#!/bin/bash
#### Description: Show IPv4, IPv6 and MAC addresses, and many more.
#### Written by: Sotirios Roussis (aka. xtonousou) - xtonousou@gmail.com on 10-2016

### INFO
AUTHOR="xtonousou"
GMAIL="${AUTHOR}@gmail.com"
GITHUB="https://github.com/${AUTHOR}"
VERSION="1.3"

### Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
ORANGE="\033[1;33m"
NORMAL="\e[1;0m"

### Colored animation parts
MAST="${ORANGE}!${NORMAL}"
DECK_DOWN="${ORANGE}_${NORMAL}"
DECK_LEFT="${ORANGE}\\\\${NORMAL}"
DECK_RIGHT="${ORANGE}/${NORMAL}"

### Overused strings and values
NULL="/dev/null"
IPINFO="http://ipinfo.io"
IPINFO_IP="${IPINFO}/ip"
GOOGLE="google.com"
GOOGLE_DNS="8.8.8.8"
LOOPBACK="127.0.0.1"

### Dialogs
DIALOG_ALL="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}MAC${NORMAL} ]-----------------[ ${GREEN}IPv4${NORMAL} ]--------[ ${GREEN}IPv6${NORMAL} ]-----------------"
DIALOG_ALL_CIDR="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}MAC${NORMAL} ]-----------------[ ${GREEN}IPv4${NORMAL} ]------------------------[ ${GREEN}IPv6${NORMAL} ]---------------------"
DIALOG_INTERFACES="[ ${GREEN}Interface${NORMAL} ]"
DIALOG_INTERFACES_MAC="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}MAC${NORMAL} ]----------"
DIALOG_INTERFACES_GATEWAY="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}Gateway${NORMAL} ]----"
DIALOG_INTERFACES_IPV4="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv4${NORMAL} ]-------"
DIALOG_INTERFACES_IPV4_CIDR="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv4${NORMAL} ]-------"
DIALOG_INTERFACES_IPV6="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv6${NORMAL} ]-----------------"
DIALOG_INTERFACES_IPV6_CIDR="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv6${NORMAL} ]---------------------"
DIALOG_IPV4="[ ${GREEN}IPv4${NORMAL} ]"
DIALOG_IPV4_MAC="[ ${GREEN}IPv4${NORMAL} ]--------[ ${GREEN}MAC${NORMAL} ]----------"
#DIALOG_IPV6="[ ${GREEN}IPv6${NORMAL} ]"
#DIALOG_IPV6_MAC="[ ${GREEN}IPv6${NORMAL} ]--------[ ${GREEN}MAC${NORMAL} ]----------"
DIALOG_PRESS_CTRL_C="press ${GREEN}CTRL+C${NORMAL} to stop..."
DIALOG_NMAP_MAC_NOTE="try ${GREEN}ship -a${NORMAL} to list missing values"
DIALOG_ERROR="try ${GREEN}ship -h${NORMAL} or ${GREEN}ship --help${NORMAL} for more information."
DIALOG_ABORTING="${RED}aborting${NORMAL}..."
DIALOG_NO_INTERNET="no internet connection. ${DIALOG_ABORTING}"
DIALOG_NO_LOCAL_CONNECTION="local connection unavailable. ${DIALOG_ABORTING}"
DIALOG_INVALID_SERVICE="invalid URL. ${DIALOG_ABORTING}"
DIALOG_SERVER_IS_DOWN="server is down or has connectivity issues. ${DIALOG_ABORTING}"

### Arrays
ONLINE_INTERFACES_ARRAY=($(ip route | grep default | awk '{print $5}'))
INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk '{print $8}'))
IPV4_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | tail -n +2))
IPV6_CIDR_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | tail -n +2))

######################################## Functions Section  #######################################

## TODO: EDIT THIS AGAIN
# Prints help message.
function usage() {
  
	echo    1>&2 "usage: ship [option] or [option] {PARAMETER}"
	echo    1>&2 "   basic operations:"
	echo -e 1>&2 "   ${GREEN}ship -4  ${NORMAL}or ${GREEN}--ipv4 ${NORMAL}          : shows active interfaces with their IPv4 address"
	echo -e 1>&2 "   ${GREEN}ship -6  ${NORMAL}or ${GREEN}--ipv6 ${NORMAL}          : shows active interfaces with their IPv6 address"
	echo -e 1>&2 "   ${GREEN}ship -a  ${NORMAL}or ${GREEN}--all ${NORMAL}           : shows all basic info"
	echo -e 1>&2 "   ${GREEN}ship -g  ${NORMAL}or ${GREEN}--gateway ${NORMAL}       : shows the default gateway"
	echo -e 1>&2 "   ${GREEN}ship -h  ${NORMAL}or ${GREEN}--help ${NORMAL}          : shows this"
	echo -e 1>&2 "   ${GREEN}ship -i  ${NORMAL}or ${GREEN}--interfaces ${NORMAL}    : shows active interfaces"
	echo -e 1>&2 "   ${GREEN}ship -l  ${NORMAL}or ${GREEN}--local-ipv4 ${NORMAL}    : shows local IPv4 address"
	echo -e 1>&2 "   ${GREEN}ship -l6 ${NORMAL}or ${GREEN}--local-ipv6 ${NORMAL}    : shows local IPv6 address"
  echo -e 1>&2 "   ${GREEN}ship -m  ${NORMAL}or ${GREEN}--mac ${NORMAL}           : shows active interfaces with their MAC address"
  echo -e 1>&2 "   ${GREEN}ship -v  ${NORMAL}or ${GREEN}--version ${NORMAL}       : shows version of script"
	echo -e 1>&2 "   ${GREEN}ship --cidr-4 ${NORMAL}or ${GREEN}--cidr-ipv4 ${NORMAL}: shows active interfaces with their IPv4 address and CIDR"
	echo -e 1>&2 "   ${GREEN}ship --cidr-6 ${NORMAL}or ${GREEN}--cidr-ipv6 ${NORMAL}: shows active interfaces with their IPv6 address and CIDR"
	echo -e 1>&2 "   ${GREEN}ship --cidr-a ${NORMAL}or ${GREEN}--cidr-all ${NORMAL} : shows all basic info and CIDR"
	echo
	echo    1>&2 "   miscellaneous operations:"
  echo -e 1>&2 "   ${GREEN}ship -f  ${NORMAL}or ${GREEN}--find ${NORMAL}${RED}{DOMAIN}${NORMAL}  : shows the IP address of a domain"
  echo -e 1>&2 "   ${GREEN}ship -L  ${NORMAL}or ${GREEN}--location ${NORMAL}${RED}{IP}${NORMAL}  : shows location info of an IP address"
  echo -e 1>&2 "  *${GREEN}ship -p  ${NORMAL}or ${GREEN}--port ${NORMAL}  {PORT}  : shows the quantity of connections to {PORT} per IP"
	echo -e 1>&2 "   ${GREEN}ship -t ${NORMAL} or ${GREEN}--time ${NORMAL}          : shows average latency using IPv4"
	echo -e 1>&2 "   ${GREEN}ship -t6 ${NORMAL}or ${GREEN}--time-ipv6 ${NORMAL}     : shows average latency using IPv6"
  echo -e 1>&2 "   ${GREEN}ship -s ${NORMAL} or ${GREEN}--scan ${NORMAL}          : shows active hosts on network"
  echo -e 1>&2 "  *${GREEN}ship -sm ${NORMAL}or ${GREEN}--scan-mac ${NORMAL}      : shows active hosts on network with their MAC address"
	echo
  echo -e 1>&2 "${CYAN}::${NORMAL} if ${RED}{PARAMETER}${NORMAL} is not passed, the action becomes passive"
  echo -e 1>&2 "${CYAN}::${NORMAL} * require root privileges"
	exit
}

# Prints frame by frame an animated ship, and author's info.
function show_version() {
  
  for frame in $(seq 0 4); do
    clear
		animated_ship "${frame}"
  done
  exit
}

# Prints active network interfaces.
function show_interfaces() {
  
	echo -e 1>&2 "${DIALOG_INTERFACES}"
  printf "%s\n" "${INTERFACES_ARRAY[@]}"
  exit
}

# Prints active network interfaces with their MAC address.
function show_mac() {
  
  local MAC_OF
  
	echo -e 1>&2 "${DIALOG_INTERFACES_MAC}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf 1>&2 "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
  done
  exit
}

# Prints active network interfaces with their IPv4 address.
function show_ipv4() {
  
	echo -e 1>&2 "${DIALOG_INTERFACES_IPV4}"
  for i in "${!IPV4_ARRAY[@]}"; do
    printf 1>&2 "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv4 address and CIDR suffix.
function show_ipv4_cidr() {
  
	echo -e 1>&2 "${DIALOG_INTERFACES_IPV4_CIDR}"
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    printf 1>&2 "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address.
function show_ipv6() {
  
	echo -e 1>&2 "${DIALOG_INTERFACES_IPV6}"
  for i in "${!IPV6_ARRAY[@]}"; do
    printf 1>&2 "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address and CIDR suffix.
function show_ipv6_cidr() {
  
	echo -e 1>&2 "${DIALOG_INTERFACES_IPV6_CIDR}"
  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    printf 1>&2 "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info.
function show_all() {
  
  local MAC_OF
  
	echo -e 1>&2 "${DIALOG_ALL}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf 1>&2 "%s\t\t%s\t%s\t%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info and CIDR suffix.
function show_all_cidr() {
  
  local MAC_OF
  
	echo -e 1>&2 "${DIALOG_ALL_CIDR}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf 1>&2 "%s\t\t%s\t%s             \t%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}	

# Prints active network interfaces and their gateway.
function show_gateway() {
  
  local GATEWAY
  
  echo -e 1>&2 "${DIALOG_INTERFACES_GATEWAY}"
  for i in "${!ONLINE_INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(ip route | grep "${ONLINE_INTERFACES_ARRAY[i]}" | grep ^default | awk '{print $3}')
    printf 1>&2 "%s\t\t%s\n" "${ONLINE_INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done
  exit
}

# Prints the public IP address of a website or server. If $1 is empty prints user's public IP, if not, $1 should be example.com.
function show_ip_from() {
  
  local HTTP_CODE_IPINFO
  local IS_URL
  local URL
  local IP
  
  if [[ -z "$1" ]]; then
    HTTP_CODE_IPINFO=$(wget -O "${NULL}" "${IPINFO_IP}" 2>&1 | grep -F HTTP | cut -d ' ' -f 6 | head -n1)
    if [[ "${HTTP_CODE_IPINFO}" -eq "302" || "200" ]]; then
      IP=$(wget "${IPINFO_IP}" -qO -)
		  echo 1>&2 "${IP}"
      exit
	  else
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  else
    if [[ "${HTTP_CODE_IPINFO}" -eq "302" || "200" ]]; then
      HTTP_CODE_IPINFO=$(wget -O "${NULL}" "$1" 2>&1 | grep -F HTTP | cut -d ' ' -f 6 | head -n1)
		  IS_URL=$(ping -c 1 "$1" 2>"${NULL}" | grep -c "icmp")
      if [[ "${IS_URL}" -eq "0" ]]; then
        error_exit "${DIALOG_INVALID_SERVICE}"
      else
        URL="$1"
        IP=$(ping -c 1 "${URL}" 2>"${NULL}" | awk -F '[()]' '/PING/{print $2}')
        echo 1>&2 "${IP}"
        exit
      fi
    else
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  fi
}

# Prints user's local IPv4 or IPv6 address (aka. internal IP)
function show_local_ip() {
  
  local LOCAL_IPV4
  local LOCAL_IPV6
  
  case "$1" in
    "--ipv4")
      LOCAL_IPV4=$(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk '{print $2}' | cut -d "/" -f 1)
      echo 1>&2 "${LOCAL_IPV4}"
    ;;
    "--ipv6")
      LOCAL_IPV6=$(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2)
      echo 1>&2 "${LOCAL_IPV6}"
    ;;
  esac
  exit
}

# Scans live hosts on network and prints their IPv4 address with or without MAC address.
function show_live_hosts() {
  
  local ONLINE_INTERFACE
  local NETWORK_ADDRESS_CIDR
  local SCANNED_HOSTS
  local SCANNED_HOSTS_WITH_MAC
  
  ONLINE_INTERFACE=$(ip route get "${GOOGLE_DNS}" | awk -F "dev " 'NR == 1 { split($2, a, " "); print a[1] }')
  NETWORK_ADDRESS_CIDR=$(ip route | grep "${ONLINE_INTERFACE}" | egrep '[0-9]{1,3}(?:\.[0-9]{1,3}){0,3}/[0-9]+' | awk '{print $1}')
  
  case "$1" in
    "--normal")
      SCANNED_HOSTS=$(nmap -sn "${NETWORK_ADDRESS_CIDR}" -oG - | awk '/Up$/{print $2}' | sort -n)
      echo -e 1>&2 "${DIALOG_IPV4}"
      echo 1>&2 "${SCANNED_HOSTS}"
      exit
    ;;
    "--mac")
      check_root_user
      SCANNED_HOSTS_WITH_MAC=$(nmap -sn "${NETWORK_ADDRESS_CIDR}" | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print "\t"$3;}' | sort -n)
      echo -e 1>&2 "${DIALOG_IPV4_MAC}"
      echo 1>&2 "${SCANNED_HOSTS_WITH_MAC}"
      echo
      echo -e 1>&2 "${DIALOG_NMAP_MAC_NOTE}"
      exit
    ;;
  esac
}

# Prints connections and how many of them per IP.
function show_port_connections() {
  
  check_for_missing_parameter "-p" "--port" "$1"
  check_if_parameter_is_not_numerical "$1"
  check_root_user
  
  local x
  local PORT
  
  PORT="$1"
  
  clear
  while x=0; do
    clear
    echo -e 1>&2 "${DIALOG_PRESS_CTRL_C}"
    echo
    echo -e 1>&2 "[${GREEN}Count${NORMAL}]-[${GREEN}IPv4${NORMAL}]"
    netstat -np | grep :"${PORT}" | grep -v LISTEN | awk '{print $5}' | cut -d : -f 1 | uniq -c
    sleep 5
  done
}

# Prints average rtt from google.com after six pings. IPv4 or IPv6.
function show_avg_ping() {

	local HTTP_CODE_GOOGLE
  local PING_4
  local HAS_IPV6
  local PING_6
  
  HTTP_CODE_GOOGLE=$(wget -O "${NULL}" "${GOOGLE}" 2>&1 | grep -F HTTP | cut -d ' ' -f 6 | head -n1)
  
  if [[ "${HTTP_CODE_GOOGLE}" -eq "302" ]]; then
    case "$1" in
      "--ipv4")
        echo "Playing ping pong with Google, please wait..."
        PING_4=$(ping -c 6 ${GOOGLE} | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
		    echo -e "Average response time: ${GREEN}${PING_4} ms${NORMAL}"
        exit
      ;;
      "--ipv6")
        HAS_IPV6=$(lsmod | awk '{print $1}' | grep -o ipv6)
        if [[ "${HAS_IPV6}" -ne "0" ]]; then
          echo "Playing ping pong with Google, please wait..."
          PING_6=$(ping -6 -c 6 "${GOOGLE}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
		      echo -e "Average response time: ${GREEN}${PING_6} ms${NORMAL}"
          exit
        else
          echo -e "IPv6 unavailable. ${DIALOG_ABORTING}"
          exit 1
        fi
      ;;
    esac
	else
		error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
}

# Prints various location info of a domain. If $1 is empty prints user's location info, if not, $1 should be example.com.
function show_location_info() {
    
  local HTTP_CODE_IPINFO
  local IS_URL
  local URL
  local IP
  local INFO_ARRAY
  local VALUE_ARRAY
  
  HTTP_CODE_IPINFO=$(wget -O "${NULL}" "${IPINFO}" 2>&1 | grep -F HTTP | cut -d ' ' -f 6 | head -n1)
  
  if [[ -z "$1" ]]; then
    if [[ "${HTTP_CODE_IPINFO}" -eq "302" || "200" ]]; then
      INFO_ARRAY=($(wget "${IPINFO}" -qO - | sed -e 's/\"//g' | sed '1d; $d' | awk '{print $1}' | awk '{print toupper($0)}' | tr -d ':'))
      VALUE_ARRAY=($(wget "${IPINFO}" -qO - | sed -e 's/\"//g' | sed '1d; $d' | awk '{print $2}' | tr -d ','))
		  for i in "${!INFO_ARRAY[@]}"; do
        printf "${GREEN}%s${NORMAL}              \t%s\n" "${INFO_ARRAY[i]}" "${VALUE_ARRAY[i]}"
      done
      exit
	  else
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  else
    if [[ "${HTTP_CODE_IPINFO}" -eq "302" || "200" ]]; then
		  IS_URL=$(ping -c 1 "$1" 2>"${NULL}" | grep -c "icmp")
      if [[ "${IS_URL}" -eq "0" ]]; then
        error_exit "${DIALOG_INVALID_SERVICE}"
      else
        URL="$1"
        IP=$(ping -c 1 "${URL}" 2>"${NULL}" | awk -F '[()]' '/PING/{print $2}')
        INFO_ARRAY=($(wget "${IPINFO}/${IP}" -qO - | sed -e 's/\"//g' | sed '1d; $d' | awk '{print $1}' | awk '{print toupper($0)}' | tr -d ':'))
        VALUE_ARRAY=($(wget "${IPINFO}/${IP}" -qO - | sed -e 's/\"//g' | sed '1d; $d' | awk '{print $2}' | tr -d ','))
		    for i in "${!INFO_ARRAY[@]}"; do
          printf "${GREEN}%s${NORMAL}              \t%s\n" "${INFO_ARRAY[i]}" "${VALUE_ARRAY[i]}"
        done
        exit
      fi
    else
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  fi
}

################################ In-function functions section :P ################################

# Used with zero parameters: exit 1.
# Used with one parameter  : echoes parameter, usually error dialogs.
# Used with two parameters : invalid option, then echoes first parameter, usually error dialogs.
function error_exit() {
  
  if [[ -z "$1" ]]; then
    exit 1
  elif [[ -z "$2" ]]; then
    echo -e "$1"
    exit 1
  else
    echo -e "${GREEN}ship${NORMAL}: invalid option -- '$2'"
    echo -e "$1"
    exit 1
  fi
}

# Animation parts used in show_version().
function animated_ship() {
  
	case "$1" in
		"0")
			echo
			echo    "     _~"
			echo    "  _~ )_)_~"
			echo -e "  )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "  ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "  ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}             Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
    ;;
		"1")
			echo
			echo    "      _~"
			echo    "   _~ )_)_~"
			echo -e "   )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "   ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "   ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}            Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"2")
			echo
			echo    "       _~"
			echo    "    _~ )_)_~"
			echo -e "    )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "    ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "    ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}           Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"3")
			echo
			echo    "        _~"
			echo    "     _~ )_)_~"
			echo -e "     )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "     ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "     ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}          Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"4")
			echo
			echo    "         _~"
			echo    "      _~ )_)_~"
			echo -e "      )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "      ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "      ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}         Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
	esac
	sleep .5
}

# Checks for root privileges.
function check_root_user() {
  
  local ID
  
  ID=$(id -u)
  
  if [[ "${ID}" -ne "0" ]]; then
    echo -e "${GREEN}ship${NORMAL} requires ${RED}root${NORMAL} privileges for this action" 1>&2
    exit 1
  fi
}

# Checks network connection (local or internet).
function check_connectivity() {
  
  local GATEWAY
  local PING_IPV4
  
  case "$1" in
    "--local")
      GATEWAY=$(ip route | grep ^default)
      if [[ ! "${GATEWAY}" ]]; then
        error_exit "${DIALOG_NO_LOCAL_CONNECTION}"
      fi
    ;;
    "--internet")
      PING_IPV4=$(ping -q -c 1 -W 1 "${GOOGLE_DNS}" 2>"${NULL}")
      if [[ ! "${PING_IPV4}" ]]; then
        error_exit "${DIALOG_NO_INTERNET}"
      fi
    ;;
  esac
}

function check_if_parameter_is_not_numerical() {

  local PARAMETER
  
  PARAMETER="$1"
  if [[ "${PARAMETER}" != [0-9]* ]]; then
    echo 1>&2 "parameter should be an integer"
    exit 1
  fi
}

# e.g.(-f example.com). Checks if "example.com" is empty. $1 is the option, $2 is the alternative option and $3 is the parameter.
function check_for_missing_parameter() {
  
  if [[ -z "$3" ]]; then
    echo -e 1>&2 "option ${GREEN}ship $1 ${NORMAL}or ${GREEN}ship $2 ${NORMAL}requires second argument."
    echo -e 1>&2 "e.g. ${GREEN}ship $1 arg${NORMAL} or ${GREEN}ship $2 arg${NORMAL}"
    error_exit
  fi
}

# Checks tool's existance in system.
function check_for_missing_tool() {
  
  local MSG
  
  MSG="Please install ${ORANGE}$1${NORMAL} and then try again. ${RED}Aborting${NORMAL}..."
  hash "$1" 2>"${NULL}" || {
    echo -e 1>&2 "${MSG}"
    exit 1
  }
}

###################################### Initializes script. #######################################
function __init__() {
  
  if [[ -z "$1" ]]; then error_exit "${DIALOG_ERROR}"; fi
  
  while :
  do
    case "$1" in
      "-4"|"--ipv4") show_ipv4; break;;
      "-6"|"--ipv6") show_ipv6; break;;
      "-a"|"--all") show_all; break;;
      "-f"|"--find") check_connectivity "--internet"; show_ip_from "$2"; shift 2; break;;
      "-g"|"--gateway") check_connectivity "--local"; show_gateway; break;;
      "-h"|"--help") usage; break;;
      "-i"|"--interfaces") show_interfaces; break;;
      "-L"|"--location") check_connectivity "--internet"; show_location_info "$2"; shift 2; break;;
      "-l"|"--local-ipv4") check_connectivity "--local"; show_local_ip "--ipv4"; break;;
      "-l6"|"--local-ipv6") check_connectivity "--local"; show_local_ip "--ipv6"; break;;
      "-p"|"--port") check_connectivity "--internet"; show_port_connections "$2"; shift 2; break;;
      "-m"|"--mac") show_mac; break;;
      "-t"|"--time") check_connectivity "--internet"; show_avg_ping --ipv4; break;;
      "-t6"|"--time-ipv6") check_connectivity "--internet"; show_avg_ping --ipv6; break;;
      "-s"|"--scan") check_for_missing_tool "nmap"; check_connectivity "--internet"; show_live_hosts --normal; break;;
      "-sm"|"--scan-mac") check_for_missing_tool "nmap"; check_connectivity "--internet"; show_live_hosts --mac; break;;
      "-v"|"--version") show_version; break;;
      "--cidr-4"|"--cidr-ipv4") show_ipv4_cidr; break;;
      "--cidr-6"|"--cidr-ipv6") show_ipv6_cidr; break;;
      "--cidr-a"|"--cidr-all") show_all_cidr; break;;
      *) error_exit "${DIALOG_ERROR}" "$1"; break;;
    esac
  done
}

__init__ "$1" "$2"
