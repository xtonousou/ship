#!/bin/bash
#### Description: Show IPv4, IPv6 and MAC addresses, and many more.
#### Written by: Sotirios Roussis (aka. xtonousou) - xtonousou@gmail.com on 10-2016

### INFO
AUTHOR="xtonousou"
GMAIL="${AUTHOR}@gmail.com"
GITHUB="https://github.com/${AUTHOR}"
VERSION="1.2"

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

### Commonly used strings
NULL="/dev/null"
IPINFO="http://ipinfo.io/ip"
GOOGLE="google.com"
GOOGLE_DNS="8.8.8.8"

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
DIALOG_NMAP_MAC_NOTE="try ${GREEN}ship -a${NORMAL} to list missing values"
DIALOG_ERROR="Try ${GREEN}ship -h${NORMAL} or ${GREEN}ship --help${NORMAL} for more information."
DIALOG_ABORTING="${RED}Aborting${NORMAL}..."
DIALOG_NO_INTERNET="No internet connection. ${DIALOG_ABORTING}"
DIALOG_NO_LOCAL_CONNECTION="Local connection unavailable. ${DIALOG_ABORTING}"
DIALOG_INVALID_SERVICE="Invalid URL. ${DIALOG_ABORTING}"

### Arrays
ONLINE_INTERFACES_ARRAY=($(ip route | grep default | awk '{print $5}'))
INTERFACES_ARRAY=($(ip -4 a | grep : | awk '{print $2}' | tr -d ':'))
IPV4_ARRAY=($(ip -4 a show | grep inet | awk '{print $2}' | sed 's/\/.*//'))
IPV6_ARRAY=($(ip -6 a show | grep inet | awk '{print $2}' | sed 's/\/.*//'))
IPV4_CIDR_ARRAY=($(ip -4 a show | grep inet | awk '{print $2}' | sed -e 's#.*\/\(\)#\1#'))
IPV6_CIDR_ARRAY=($(ip -6 a show | grep inet | awk '{print $2}' | sed -e 's#.*\/\(\)#\1#'))

# Prints help message.
function usage() {
  
	echo    "usage: ship [option] or [option] {operand}"
	echo    "   basic operations:"
	echo -e "   ${GREEN}ship -4 ${NORMAL}or ${GREEN}--ipv4 ${NORMAL}           : shows active interfaces with their IPv4 address"
	echo -e "   ${GREEN}ship -6 ${NORMAL}or ${GREEN}--ipv6 ${NORMAL}           : shows active interfaces with their IPv6 address"
	echo -e "   ${GREEN}ship -a ${NORMAL}or ${GREEN}--all ${NORMAL}            : shows all basic info"
  echo -e "   ${GREEN}ship -f ${NORMAL}or ${GREEN}--find ${NORMAL}domain     : shows the IP address from a domain"
	echo -e "   ${GREEN}ship -g ${NORMAL}or ${GREEN}--gateway ${NORMAL}        : shows the default gateway"
	echo -e "   ${GREEN}ship -h ${NORMAL}or ${GREEN}--help ${NORMAL}           : shows this"
	echo -e "   ${GREEN}ship -i ${NORMAL}or ${GREEN}--interfaces ${NORMAL}     : shows active interfaces"
	echo -e "   ${GREEN}ship -l ${NORMAL}or ${GREEN}--local-ip ${NORMAL}       : shows your local IP address"
  echo -e "   ${GREEN}ship -m ${NORMAL}or ${GREEN}--mac ${NORMAL}            : shows active interfaces with their MAC address"
  echo -e "   ${GREEN}ship -v ${NORMAL}or ${GREEN}--version ${NORMAL}        : shows version of script"
	echo -e "   ${GREEN}ship --cidr-4 ${NORMAL}or ${GREEN}--cidr-ipv4 ${NORMAL}: shows active interfaces with their IPv4 address and CIDR"
	echo -e "   ${GREEN}ship --cidr-6 ${NORMAL}or ${GREEN}--cidr-ipv6 ${NORMAL}: shows active interfaces with their IPv6 address and CIDR"
	echo -e "   ${GREEN}ship --cidr-a ${NORMAL}or ${GREEN}--cidr-all ${NORMAL} : shows all basic info and CIDR"
	echo
	echo    "   miscellaneous operations:"
	echo -e "   ${GREEN}ship -p ${NORMAL} or ${GREEN}--public-ip ${NORMAL}     : shows your public IP address"
	echo -e "   ${GREEN}ship -t ${NORMAL} or ${GREEN}--time ${NORMAL}          : shows average latency using IPv4"
	echo -e "   ${GREEN}ship -t6 ${NORMAL}or ${GREEN}--time-ipv6 ${NORMAL}     : shows average latency using IPv6"
  echo -e "   ${GREEN}ship -s ${NORMAL} or ${GREEN}--scan ${NORMAL}          : shows active hosts on network"
  echo -e "   ${RED}ship -sM ${NORMAL}or ${RED}--scan-mac ${NORMAL}      : shows active hosts on network with their MAC address"
	echo
  echo -e "Commands shown in ${RED}RED${NORMAL} require root privileges"
	exit
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

# Prints frame by frame an animated ship, see animated_ship(), and author's info.
function show_version() {
  
  for frame in $(seq 0 4); do
    clear
		animated_ship "${frame}"
  done
  exit
}

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

# Checks for root privileges.
function check_root_user() {
  
  if [[ "$(id -u)" -ne "0" ]]; then
    echo -e "${GREEN}ship${NORMAL} requires ${RED}root${NORMAL} privileges for this action" 1>&2
    exit 1
  fi
}

# Checks network connection (local and internet).
function check_connectivity() {
  
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

# e.g.(-f example.com). Checks if "example.com" is empty. $1 is the option, $2 is the alternative option and $3 is the operand.
function check_for_missing_operand() {
  
  if [[ -z "$3" ]]; then
    echo -e >&2 "option ${GREEN}ship $1 ${NORMAL}or ${GREEN}ship $2 ${NORMAL}requires second argument."
    echo -e >&2 "e.g. ${GREEN}ship $1 arg${NORMAL} or ${GREEN}ship $2 arg${NORMAL}"
    error_exit
  fi
}

# Checks tool's existance in system.
function check_for_missing_tool() {
  
  MSG="Please install ${ORANGE}$1${NORMAL} and then try again. ${RED}Aborting${NORMAL}..."
  hash "$1" 2>"${NULL}" || {
    echo -e >&2 "${MSG}"
    exit 1
  }
}

# Prints active network interfaces.
function show_interfaces() {
  
	echo -e "${DIALOG_INTERFACES}"
  printf "%s\n" "${INTERFACES_ARRAY[@]}"
  exit
}

# Prints active network interfaces with their MAC address.
function show_mac() {
  
	echo -e "${DIALOG_INTERFACES_MAC}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
  done
  exit
}

# Prints active network interfaces with their IPv4 address.
function show_ipv4() {
  
	echo -e "${DIALOG_INTERFACES_IPV4}"
  for i in "${!IPV4_ARRAY[@]}"; do
    printf "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv4 address and CIDR suffix.
function show_ipv4_cidr() {
  
	echo -e "${DIALOG_INTERFACES_IPV4_CIDR}"
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    printf "%s\t\t%s${RED}/%s${NORMAL}\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address.
function show_ipv6() {
  
	echo -e "${DIALOG_INTERFACES_IPV6}"
  for i in "${!IPV6_ARRAY[@]}"; do
    printf "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address and CIDR suffix.
function show_ipv6_cidr() {
  
	echo -e "${DIALOG_INTERFACES_IPV6_CIDR}"
  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    printf "%s\t\t%s${RED}/%s${NORMAL}\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info.
function show_all() {
  
	echo -e "${DIALOG_ALL}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf "%s\t\t%s\t%s\t%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info and CIDR suffix.
function show_all_cidr() {
  
	echo -e "${DIALOG_ALL_CIDR}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf "%s\t\t%s\t%s${RED}/%s${NORMAL}             \t%s${RED}/%s${NORMAL}\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}	

# Prints active network interfaces and their gateway.
function show_gateway() {
  
  echo -e "${DIALOG_INTERFACES_GATEWAY}"
  for i in "${!ONLINE_INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(ip route | grep "${ONLINE_INTERFACES_ARRAY[i]}" | grep ^default | awk '{print $3}')
    printf "%s\t\t%s\n" "${ONLINE_INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done
  exit
}

# Prints the IP address of a website or server.
function show_ip_from() {
  
  check_for_missing_operand "-f" "--find" "$1"
  IS_URL=$(ping -c 1 "$1" 2>"${NULL}" | grep -c "icmp")
  if [[ "$IS_URL" -eq "0" ]]; then
    error_exit "${DIALOG_INVALID_SERVICE}"
  else
    URL="$1"
    DNS_IP=$(ping -c 1 "${URL}" 2>"${NULL}" | awk -F '[()]' '/PING/{print $2}')
    echo "${DNS_IP}"
    exit
  fi
  #echo -e "${DIALOG_NO_INTERNET}"
}

# Prints user's internal IP address (aka. local IP)
function show_local_ip() {
  
  GET_LOCAL_IP=$(ip route get "${GOOGLE_DNS}" | head -1 | cut -d ' ' -f 8)
  echo "${GET_LOCAL_IP}"
  exit
}

# Prints user's external IP address (aka. public IP)
function show_public_ip() {
  
	HTTP_CODE_IPINFO=$(wget -O "${NULL}" "${IPINFO}" 2>&1 | grep -F HTTP | cut -d ' ' -f 6 | head -n1)
  if [[ "${HTTP_CODE_IPINFO}" -eq "200" ]]; then
		wget "${IPINFO}" -qO -
    exit
	else
		error_exit "${DIALOG_NO_INTERNET}" # TODO: add alternative message?
	fi
}

# Scans live hosts on network and prints their IPv4 address with or without MAC address.
function show_live_hosts() {
  
  ONLINE_INTERFACE=$(ip route get "${GOOGLE_DNS}" | awk -F "dev " 'NR == 1 { split($2, a, " "); print a[1] }')
  NETWORK_ADDRESS_CIDR=$(ip route | grep "${ONLINE_INTERFACE}" | egrep '[0-9]{1,3}(?:\.[0-9]{1,3}){0,3}/[0-9]+' | awk '{print $1}')
  case "$1" in
    "--normal")
      SCANNED_HOSTS=$(nmap -sn "${NETWORK_ADDRESS_CIDR}" -oG - | awk '/Up$/{print $2}' | sort -n)
      echo -e "${DIALOG_IPV4}"
      echo "${SCANNED_HOSTS}"
      exit
    ;;
    "--mac")
      check_root_user
      SCANNED_HOSTS_WITH_MAC=$(nmap -sn "${NETWORK_ADDRESS_CIDR}" | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print "\t"$3;}' | sort -n)
      echo -e "${DIALOG_IPV4_MAC}"
      echo "${SCANNED_HOSTS_WITH_MAC}"
      echo
      echo -e "${DIALOG_NMAP_MAC_NOTE}"
      exit
    ;;
  esac
}

# Prints average rtt from google.com after six pings. IPv4 or IPv6.
function show_avg_ping() {

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
		error_exit "${DIALOG_NO_INTERNET}"
	fi
}

# Initializes script.
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
      "-l"|"--local-ip") check_connectivity "--local"; show_local_ip; break;;
      "-m"|"--mac") show_mac; break;;
      "-p"|"--public-ip") check_connectivity "--internet"; show_public_ip; break;;
      "-t"|"--time") check_connectivity "--internet"; show_avg_ping --ipv4; break;;
      "-t6"|"--time-ipv6") check_connectivity "--internet"; show_avg_ping --ipv6; break;;
      "-s"|"--scan") check_for_missing_tool "nmap"; check_connectivity "--internet"; show_live_hosts --normal; break;;
      "-sM"|"--scan-mac") check_for_missing_tool "nmap"; check_connectivity "--internet"; show_live_hosts --mac; break;;
      "-v"|"--version") show_version; break;;
      "--cidr-4"|"--cidr-ipv4") show_ipv4_cidr; break;;
      "--cidr-6"|"--cidr-ipv6") show_ipv6_cidr; break;;
      "--cidr-a"|"--cidr-all") show_all_cidr; break;;
      *) error_exit "${DIALOG_ERROR}" "$1"; break;;
    esac
  done
}

__init__ "$1" "$2"
