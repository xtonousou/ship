#!/bin/bash
#
# ship stands for show ip
# do the math
#

### Flags
DEV=0

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
DIALOG_INTERFACES="[ ${GREEN}Interface${NORMAL} ]"
DIALOG_MAC="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}MAC${NORMAL} ]----------"
DIALOG_IPV4="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv4${NORMAL} ]-------"
DIALOG_IPV4_CIDR="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv4${NORMAL} ]-------"
DIALOG_IPV6="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv6${NORMAL} ]-----------------"
DIALOG_IPV6_CIDR="[ ${GREEN}Interface${NORMAL} ]---[ ${GREEN}IPv6${NORMAL} ]---------------------"
DIALOG_ERROR="${GREEN}ship -h${NORMAL} or ${GREEN}ship --help${NORMAL} for usage"

### Commands
INTERFACES_ARRAY=($(ip -4 a | grep : | awk {'print $2'} | tr -d ':'))
MAC_ARRAY=($(ip -4 a show | grep inet | awk {'print $2'} | sed 's/\/.*//'))
IPV4_ARRAY=($(ip -4 a show | grep inet | awk {'print $2'} | sed 's/\/.*//'))
IPV6_ARRAY=($(ip -6 a show | grep inet | awk {'print $2'} | sed 's/\/.*//'))
IPV4_CIDR_ARRAY=($(ip -4 a show | grep inet | awk {'print $2'} | sed -e 's#.*\/\(\)#\1#'))
IPV6_CIDR_ARRAY=($(ip -6 a show | grep inet | awk {'print $2'} | sed -e 's#.*\/\(\)#\1#'))

function usage() {
	echo    "usage: ship <option>"
	echo    "   basic operations:"
	echo -e "   ${GREEN}ship -4 ${NORMAL}or ${GREEN}--ipv4 ${NORMAL}           : shows active interfaces with IPv4 addresses"
	echo -e "   ${GREEN}ship -6 ${NORMAL}or ${GREEN}--ipv6 ${NORMAL}           : shows active interfaces with IPv6 addresses"
	echo -e "   ${GREEN}ship -a ${NORMAL}or ${GREEN}--all ${NORMAL}            : shows all basic info"
	echo -e "   ${GREEN}ship -h ${NORMAL}or ${GREEN}--help ${NORMAL}           : shows this"
	echo -e "   ${GREEN}ship -i ${NORMAL}or ${GREEN}--interfaces ${NORMAL}     : shows active interfaces"
	echo -e "   ${GREEN}ship -m ${NORMAL}or ${GREEN}--mac ${NORMAL}            : shows active interfaces with MAC  addresses"
	echo -e "   ${GREEN}ship --cidr-4 ${NORMAL}or ${GREEN}--cidr-ipv4 ${NORMAL}: shows active interfaces with IPv4 addresses and CIDR"
	echo -e "   ${GREEN}ship --cidr-6 ${NORMAL}or ${GREEN}--cidr-ipv6 ${NORMAL}: shows active interfaces with IPv6 addresses and CIDR"
	echo -e "   ${GREEN}ship --cidr-a ${NORMAL}or ${GREEN}--cidr-all ${NORMAL} : shows all basic info with CIDR"
	echo
	echo    "   miscellaneous operations:"
	echo -e "   ${GREEN}ship --animate ${NORMAL}              : shows an animated ship :)"
	echo -e "   ${GREEN}ship -p ${NORMAL}or ${GREEN}--public-ip ${NORMAL}      : shows your public IP"
	echo -e "   ${GREEN}ship -t4 ${NORMAL}or ${GREEN}--time-ipv4 ${NORMAL}           : shows latency using IPv4 (Source: Google)"
	echo -e "   ${GREEN}ship -t6 ${NORMAL}or ${GREEN}--time-ipv6 ${NORMAL}           : shows latency using IPv6 (Source: Google)"
	if [[ "$DEV" -eq 1 ]]; then
		echo
		echo -e "Commands shown in ${RED}RED${NORMAL} are under development..."
	fi
	exit
}

function sailing_ship() {
	case $1 in
		0)
			echo
			echo    "     _~"
			echo    "  _~ )_)_~"
			echo -e "  )_))_))_)		Mail ..: ${GREEN}xtonousou@gmail.com${NORMAL}"
			echo -e "  ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github : ${GREEN}https://github.com/xtonousou${NORMAL}"
			echo -e "  ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		1)
			echo
			echo    "      _~"
			echo    "   _~ )_)_~"
			echo -e "   )_))_))_)		Mail ..: ${GREEN}xtonousou@gmail.com${NORMAL}"
			echo -e "   ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github : ${GREEN}https://github.com/xtonousou${NORMAL}"
			echo -e "   ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		2)
			echo
			echo    "       _~"
			echo    "    _~ )_)_~"
			echo -e "    )_))_))_)		Mail ..: ${GREEN}xtonousou@gmail.com${NORMAL}"
			echo -e "    ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github : ${GREEN}https://github.com/xtonousou${NORMAL}"
			echo -e "    ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		3)
			echo
			echo    "        _~"
			echo    "     _~ )_)_~"
			echo -e "     )_))_))_)		Mail ..: ${GREEN}xtonousou@gmail.com${NORMAL}"
			echo -e "     ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github : ${GREEN}https://github.com/xtonousou${NORMAL}"
			echo -e "     ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
		4)
			echo
			echo    "         _~"
			echo    "      _~ )_)_~"
			echo -e "      )_))_))_)		Mail ..: ${GREEN}xtonousou@gmail.com${NORMAL}"
			echo -e "      ${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}${DECK_DOWN}${MAST}${DECK_DOWN}		Github : ${GREEN}https://github.com/xtonousou${NORMAL}"
			echo -e "      ${DECK_LEFT}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_DOWN}${DECK_RIGHT}"
			echo -e "  ${LIGHT_BLUE}~~~~~~~~~~~~~~~~~${NORMAL}"
		;;
	esac
	sleep 0.4
}

function show_animated_sailing_ship() {
	for ((frame = 0; frame <= 4; frame++)); do
		clear
		sailing_ship ${frame}
	done
}

function show_interfaces() {
	echo -e $DIALOG_INTERFACES
	for ((i = 0; i < ${#IPV4_ARRAY[@]}; i++)); do
		echo "${INTERFACES_ARRAY[i]}"
	done
}

function show_mac() {
	echo -e $DIALOG_MAC
	for ((i = 0; i < ${#IPV4_ARRAY[@]}; i++)); do
		MAC_OF=`ip link show ${INTERFACES_ARRAY[i]} | grep link | awk {'print $2'}`
		echo -e "${INTERFACES_ARRAY[i]}\t\t$MAC_OF\t"
	done
}

function show_ipv4() {
	echo -e $DIALOG_IPV4
	for ((i = 0; i < ${#IPV4_ARRAY[@]}; i++)); do
		echo -e "${INTERFACES_ARRAY[i]}\t\t${IPV4_ARRAY[i]}";
	done	
}

function show_ipv4_cidr() {
	echo -e $DIALOG_IPV4_CIDR
	for ((i = 0; i < ${#IPV4_CIDR_ARRAY[@]}; i++)); do
		echo -e "${INTERFACES_ARRAY[i]}\t\t${IPV4_ARRAY[i]}${RED}/${IPV4_CIDR_ARRAY[i]}${NORMAL}";
	done	
}

function show_ipv6() {
	echo -e $DIALOG_IPV6
	for ((i = 0; i < ${#IPV6_ARRAY[@]}; i++)); do
		echo -e "${INTERFACES_ARRAY[i]}\t\t${IPV6_ARRAY[i]}";
	done	
}

function show_ipv6_cidr() {
	echo -e $DIALOG_IPV6_CIDR
	for ((i = 0; i < ${#IPV6_CIDR_ARRAY[@]}; i++)); do
		echo -e "${INTERFACES_ARRAY[i]}\t\t${IPV6_ARRAY[i]}${RED}/${IPV6_CIDR_ARRAY[i]}${NORMAL}";
	done	
}

function show_all() {
	echo -e $DIALOG_ALL
	for ((i = 0; i < ${#IPV4_ARRAY[@]}; i++)); do
		MAC_OF=`ip link show ${INTERFACES_ARRAY[i]} | grep link | awk {'print $2'}`
		echo -e "${INTERFACES_ARRAY[i]}\t\t$MAC_OF\t${IPV4_ARRAY[i]}\t${IPV6_ARRAY[i]}"
	done
}

function show_all_cidr() {
	echo -e $DIALOG_ALL_CIDR
	for ((i = 0; i < ${#IPV4_ARRAY[@]}; i++)); do
		MAC_OF=`ip link show ${INTERFACES_ARRAY[i]} | grep link | awk {'print $2'}`
		echo -e "${INTERFACES_ARRAY[i]}\t\t$MAC_OF\t${IPV4_ARRAY[i]}${RED}/${IPV4_CIDR_ARRAY[i]}${NORMAL}             \t${IPV6_ARRAY[i]}${RED}/${IPV6_CIDR_ARRAY[i]}${NORMAL}"
	done
}	

function show_public_ip() {
	PUBLIC_IP=$(curl -s $IPECHO; echo; 2>&1)
	HTTP_CODE_IPECHO=$(curl -Is $IPECHO | head -1 | awk {'print $2'} 2>&1)
	
	if [ "${HTTP_CODE_IPECHO}" = "200" ]; then
		echo "${PUBLIC_IP}"
	else
		echo "Please check your internet connection"
	fi
}

function show_avg_ping() {
	HTTP_CODE_GOOGLE=$(curl -Is $GOOGLE | head -1 | awk {'print $2'} 2>&1)
	
	if [[ "${HTTP_CODE_GOOGLE}" = "302" ]]; then
		echo "Playing ping pong with Google, please wait..."
		RESPONSE_TIME=$(ping -c 6 $GOOGLE | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
		echo -e "Average response time: ${GREEN}${RESPONSE_TIME} ms${NORMAL}"
	else
		echo "Please check your internet connection"
	fi
}

function __init__() {
	if [[ "$#" -ne 1 ]]; then
		echo -e "${DIALOG_ERROR}"
		exit
	elif [[ "$#" -eq 1 ]]; then
		case "$1" in
			"-4"|"--ipv4") show_ipv4;;
			"-6"|"--ipv6") show_ipv6;;
			"-a"|"--all") show_all;;
			"-h"|"--help") usage;;
			"-i"|"--interfaces") show_interfaces;;
			"-m"|"--mac") show_mac;;
			"-p"|"--public-ip") show_public_ip --public;;
			"-t4"|"--time-ipv4") show_avg_ping -4;;
			"-t6"|"--time-ipv6") show_avg_ping -6;;
			"--animate") show_animated_sailing_ship;;
			"--cidr-4"|"--cidr-ipv4") show_ipv4_cidr;;
			"--cidr-6"|"--cidr-ipv6") show_ipv6_cidr;;
			"--cidr-a"|"--cidr-all") show_all_cidr;;			
			*) echo -e "${DIALOG_ERROR}"; exit;;
		esac
	fi
}

__init__ $1
