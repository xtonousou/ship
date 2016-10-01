#!/bin/bash
#
# ship stands for show ip
# do the math
#

### INFO
DEV="1"
GMAIL="xtonousou@gmail.com"
GITHUB="https://github.com/xtonousou"
VERSION="1.1"

### Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
LIGHT_BLUE="\033[1;36m"
ORANGE="\033[1;33m"
NORMAL="\e[1;0m"

### Colored animation parts
MAST="${ORANGE}!${NORMAL}"
DECK_DOWN="${ORANGE}_${NORMAL}"
DECK_LEFT="${ORANGE}\\\\${NORMAL}"
DECK_RIGHT="${ORANGE}/${NORMAL}"

### Websites
IPECHO="ipecho.net/plain"
GOOGLE="google.com"

### Dialogs
DIALOG_ALL="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}MAC${NORMAL} ]-----------------[ ${GREEN}IPv4${NORMAL} ]--------[ ${GREEN}IPv6${NORMAL} ]-----------------"
DIALOG_ALL_CIDR="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}MAC${NORMAL} ]-----------------[ ${GREEN}IPv4${NORMAL} ]------------------------[ ${GREEN}IPv6${NORMAL} ]---------------------"
DIALOG_GATEWAY="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}Gateway${NORMAL} ]----"
DIALOG_INTERFACES="[ ${GREEN}Interface${NORMAL} ]"
DIALOG_MAC="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}MAC${NORMAL} ]----------"
DIALOG_IPV4_ONLY="[ ${GREEN}IPv4${NORMAL} ]"
DIALOG_IPV4="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv4${NORMAL} ]-------"
DIALOG_IPV4_CIDR="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv4${NORMAL} ]-------"
#DIALOG_IPV6_ONLY="[ ${GREEN}IPv6${NORMAL} ]"
DIALOG_IPV6="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv6${NORMAL} ]-----------------"
DIALOG_IPV6_CIDR="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv6${NORMAL} ]---------------------"
DIALOG_ERROR="${GREEN}ship -h${NORMAL} or ${GREEN}ship --help${NORMAL} for usage"

### Commands
HAS_IPV6=$(lsmod | awk '{print $1}' | grep -o ipv6)

### Arrays
ONLINE_INTERFACES_ARRAY=($(ip route | grep default | awk '{print $5}'))
INTERFACES_ARRAY=($(ip -4 a | grep : | awk '{print $2}' | tr -d ':'))
IPV4_ARRAY=($(ip -4 a show | grep inet | awk '{print $2}' | sed 's/\/.*//'))
IPV6_ARRAY=($(ip -6 a show | grep inet | awk '{print $2}' | sed 's/\/.*//'))
IPV4_CIDR_ARRAY=($(ip -4 a show | grep inet | awk '{print $2}' | sed -e 's#.*\/\(\)#\1#'))
IPV6_CIDR_ARRAY=($(ip -6 a show | grep inet | awk '{print $2}' | sed -e 's#.*\/\(\)#\1#'))

function usage() {
	echo    "usage: ship <option>"
	echo    "   basic operations:"
	echo -e "   ${GREEN}ship -4 ${NORMAL}or ${GREEN}--ipv4 ${NORMAL}           : shows active interfaces with IPv4 addresses"
	echo -e "   ${GREEN}ship -6 ${NORMAL}or ${GREEN}--ipv6 ${NORMAL}           : shows active interfaces with IPv6 addresses"
	echo -e "   ${GREEN}ship -a ${NORMAL}or ${GREEN}--all ${NORMAL}            : shows all basic info"
	echo -e "   ${GREEN}ship -g ${NORMAL}or ${GREEN}--gateway ${NORMAL}        : shows the default gateway"
	echo -e "   ${GREEN}ship -h ${NORMAL}or ${GREEN}--help ${NORMAL}           : shows this"
	echo -e "   ${GREEN}ship -i ${NORMAL}or ${GREEN}--interfaces ${NORMAL}     : shows active interfaces"
  echo -e "   ${GREEN}ship -m ${NORMAL}or ${GREEN}--mac ${NORMAL}            : shows active interfaces with MAC  addresses"
  echo -e "   ${GREEN}ship -v ${NORMAL}or ${GREEN}--version ${NORMAL}        : shows version of script"
	echo -e "   ${GREEN}ship --cidr-4 ${NORMAL}or ${GREEN}--cidr-ipv4 ${NORMAL}: shows active interfaces with IPv4 addresses and CIDR"
	echo -e "   ${GREEN}ship --cidr-6 ${NORMAL}or ${GREEN}--cidr-ipv6 ${NORMAL}: shows active interfaces with IPv6 addresses and CIDR"
	echo -e "   ${GREEN}ship --cidr-a ${NORMAL}or ${GREEN}--cidr-all ${NORMAL} : shows all basic info with CIDR"
	echo
	echo    "   miscellaneous operations:"
	echo -e "   ${GREEN}ship -p ${NORMAL} or ${GREEN}--public-ip ${NORMAL}     : shows your public IP"
	echo -e "   ${GREEN}ship -t4 ${NORMAL}or ${GREEN}--time-ipv4 ${NORMAL}     : shows latency using IPv4 (Source: Google)"
	echo -e "   ${GREEN}ship -t6 ${NORMAL}or ${GREEN}--time-ipv6 ${NORMAL}     : shows latency using IPv6 (Source: Google)"
  echo -e "   ${GREEN}ship -s ${NORMAL} or ${GREEN}--scan ${NORMAL}          : shows active hosts on network"
  echo -e "   ${GREEN}ship -s2 ${NORMAL}or ${GREEN}--scan-2 ${NORMAL}        : shows active hosts on network (more accurate, more time)"
	if [[ "$DEV" -eq "1" ]]; then
		echo
		echo -e "Commands shown in ${RED}RED${NORMAL} are under development..."
	fi
	exit
}

function animated_ship() {
	case "$1" in
		"0")
			echo
			echo    "     _~"
			echo    "  _~ )_)_~"
			echo -e "  )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "  ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "  ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}             Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"1")
			echo
			echo    "      _~"
			echo    "   _~ )_)_~"
			echo -e "   )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "   ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "   ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}            Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"2")
			echo
			echo    "       _~"
			echo    "    _~ )_)_~"
			echo -e "    )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "    ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "    ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}           Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"3")
			echo
			echo    "        _~"
			echo    "     _~ )_)_~"
			echo -e "     )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "     ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "     ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}          Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		"4")
			echo
			echo    "         _~"
			echo    "      _~ )_)_~"
			echo -e "      )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
			echo -e "      ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github .: ${GREEN}${GITHUB}${NORMAL}"
			echo -e "      ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}         Version : ${GREEN}${VERSION}${NORMAL}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
	esac
	sleep ".5"
}

function show_version() {
  for frame in $(seq 0 4); do
    clear
		animated_ship "${frame}"
  done
}

function show_interfaces() {
	echo -e "${DIALOG_INTERFACES}"
  printf "%s\n" "${INTERFACES_ARRAY[@]}"
}

function show_mac() {
	echo -e "${DIALOG_MAC}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
  done
}

function show_ipv4() {
	echo -e "${DIALOG_IPV4}"
  for i in "${!IPV4_ARRAY[@]}"; do
    printf "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done
}

function show_ipv4_cidr() {
	echo -e "${DIALOG_IPV4_CIDR}"
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    printf "%s\t\t%s${RED}/%s${NORMAL}\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done
}

function show_ipv6() {
	echo -e "${DIALOG_IPV6}"
  for i in "${!IPV6_ARRAY[@]}"; do
    printf "%s\t\t%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done	
}

function show_ipv6_cidr() {
	echo -e "${DIALOG_IPV6_CIDR}"
  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    printf "%s\t\t%s${RED}/%s${NORMAL}\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
}

function show_all() {
	echo -e "${DIALOG_ALL}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf "%s\t\t%s\t%s\t%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
}

function show_all_cidr() {
	echo -e "${DIALOG_ALL_CIDR}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}')
    printf "%s\t\t%s\t%s${RED}/%s${NORMAL}             \t%s${RED}/%s${NORMAL}\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
}	

function show_gateway() {
  echo -e "${DIALOG_GATEWAY}"
  for i in "${!ONLINE_INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(route -n | grep "${ONLINE_INTERFACES_ARRAY[i]}" | awk '{print $2}' | head -n1)
    printf "%s\t\t%s\n" "${ONLINE_INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done
}

function show_public_ip() {
	PUBLIC_IP=$(curl -s ${IPECHO}; echo; 2>&1)
	HTTP_CODE_IPECHO=$(curl -Is ${IPECHO} | head -1 | awk '{print $2}' 2>&1)
	
	if [[ "${HTTP_CODE_IPECHO}" = "200" ]]; then
		echo "${PUBLIC_IP}"
	else
		echo "Please check your internet connection"
	fi
}

function show_avg_ping() {
	HTTP_CODE_GOOGLE=$(curl -Is ${GOOGLE} | head -1 | awk '{print $2}' 2>&1)
	
	if [[ "${HTTP_CODE_GOOGLE}" = "302" ]]; then
    case "$1" in
      "--ipv4")
        echo "Playing ping pong with Google, please wait..."
		    RESPONSE_TIME=$(ping -c 6 ${GOOGLE} | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
		    echo -e "Average response time: ${GREEN}${RESPONSE_TIME} ms${NORMAL}"
      ;;
      "--ipv6")
        HAS_IPV6=$(lsmod | awk '{print $1}' | grep -o ipv6)
        if [[ "${HAS_IPV6}" -ne "0" ]]; then
          echo "Playing ping pong with Google, please wait..."
		      RESPONSE_TIME=$(ping -6 -c 6 ${GOOGLE} | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
		      echo -e "Average response time: ${GREEN}${RESPONSE_TIME} ms${NORMAL}"
        else
          echo "IPv6 unavailable"
        fi
      ;;
    esac
	else
		echo "Please check your internet connection"
	fi
}

function show_live_hosts() {
  # TODO ADD IPv6 OR NOT? WOULD TAKE DAYS...OR YEARS?
  hash nmap 2>/dev/null || { echo -e >&2 "nmap is required and it's not installed. ${RED}Aborting${NORMAL}"; exit 1; }
  ONLINE_INTERFACE=$(route -n | awk '/0\.0\.0\.0/ && /UG/ {print $NF; exit}')
  NETWORK_ADDRESS=$(route -n | grep "${ONLINE_INTERFACE}" | awk '{print $1}' | sed '1d')
  NETWORK_ADDRESS_CIDR=$(ip route | grep "${NETWORK_ADDRESS}" | awk '{print $1}')
  case "$1" in
    "--normal")
      NMAP=$(nmap -sP "${NETWORK_ADDRESS_CIDR}" | sed '2d' | awk '{print $5}' | sed '1d' | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
    ;;
    "--all-ports")
      NMAP=$(nmap -p- "${NETWORK_ADDRESS_CIDR}" | sed '2d' | awk '{print $5}' | sed '1d' | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
    ;;
  esac
  echo -e "${DIALOG_IPV4_ONLY}"
  echo "${NMAP}"
}

function __init__() {
	if [[ "$#" -ne "1" ]]; then
		echo -e "${DIALOG_ERROR}"
		exit
	elif [[ "$#" -eq "1" ]]; then
		case "$1" in
			"-4"|"--ipv4") show_ipv4;;
			"-6"|"--ipv6") show_ipv6;;
			"-a"|"--all") show_all;;
			"-g"|"--gateway") show_gateway;;
			"-h"|"--help") usage;;
			"-i"|"--interfaces") show_interfaces;;
			"-m"|"--mac") show_mac;;
			"-p"|"--public-ip") show_public_ip;;
      "-t4"|"--time-ipv4") show_avg_ping --ipv4;;
			"-t6"|"--time-ipv6") show_avg_ping --ipv6;;
      "-s"|"--scan") show_live_hosts --normal;;
      "-s2"|"--scan-2") show_live_hosts --all-ports;;
			"-v"|"--version") show_version;;
			"--cidr-4"|"--cidr-ipv4") show_ipv4_cidr;;
			"--cidr-6"|"--cidr-ipv6") show_ipv6_cidr;;
			"--cidr-a"|"--cidr-all") show_all_cidr;;			
			*) echo -e "${DIALOG_ERROR}"; exit;;
		esac
	fi
}

__init__ "$1"
