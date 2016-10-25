#!/bin/bash
#### Description      : Show IPv4, IPv6 and MAC addresses, and many more.
#### Written by       : Sotirios Roussis (aka. xtonousou) - xtonousou@gmail.com on 10-2016
#### Known limitations: ipinfo.io offers free 1,000 daily requests. (ship -F, -L)

######################## Declarations  #################################

### INFO
AUTHOR="Sotirios Roussis"
AUTHOR_NICKNAME="xtonousou"
GMAIL="${AUTHOR_NICKNAME}@gmail.com"
GITHUB="https://github.com/${AUTHOR_NICKNAME}"
VERSION="1.6"

### Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
ORANGE="\033[1;33m"
NORMAL="\e[1;0m"

### Directories, strings and domains
TMP="/tmp/ship"
NULL="/dev/null"
GOOGLE_DNS="8.8.8.8"
LOOPBACK="127.0.0.1"
IPINFO="ipinfo.io"
CDN_TEST="http://cachefly.cachefly.net/10mb.test"
SINGAPORE_TEST="http://phantom.starserverspeedtest.com/test10.zip"
USA_TEST="http://mirror.us.leaseweb.net/speedtest/10mb.bin"
AUSTRALIA_TEST="http://mirror.filearena.net/pub/speed/SpeedTest_16MB.dat"
NETHERLANDS_TEST="http://mirror.nl.leaseweb.net/speedtest/10mb.bin"
FRANCE_TEST="http://proof.ovh.net/files/10Mb.dat"
UK_TEST="http://download.thinkbroadband.com/10MB.zip"
GREECE_TEST="http://speedtest.ftp.otenet.gr/files/test10Mb.db"
SCAN="http://www.urlvoid.com/scan/"

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
DIALOG_IPV6="┌─────────────────┤${GREEN}IPV6${NORMAL}├────────────────┐"
DIALOG_SPEED="┌─┤${GREEN}INTERFACE${NORMAL}├─┬─┬─┤${GREEN}↓${NORMAL} kB/s├─┬─┬─┤${GREEN}↑${NORMAL} kB/s├──┐"
DIALOG_PORTS="┌────┤${GREEN}PROTOCOL${NORMAL}├──┬──┤${GREEN}TCP/UDP${NORMAL}├──┬┤${GREEN}PORT${NORMAL}├┐"
DIALOG_PRESS_CTRL_C="Press [CTRL+C] to stop"
DIALOG_ERROR="Try ${GREEN}ship -h${NORMAL} or ${GREEN}ship --help${NORMAL} for more information."
DIALOG_ABORTING="${RED}Aborting${NORMAL}."
DIALOG_NO_INTERNET="Internet connection unavailable. ${DIALOG_ABORTING}"
DIALOG_NO_LOCAL_CONNECTION="Local connection unavailable. ${DIALOG_ABORTING}"
DIALOG_SERVER_IS_DOWN="Destination is unreachable. Server may be down or input was invalid. ${DIALOG_ABORTING}"
DIALOG_NOT_A_NUMBER="Option should be integer. ${DIALOG_ABORTING}"
DIALOG_NO_ARGUMENTS="No arguments. ${DIALOG_ABORTING}"

##################### Basic s Section  #########################

# Prints active network interfaces with their IPv4 address.
function show_ipv4() {
  
  declare -a INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))
  declare -a IPV4_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
  
	echo -e "${DIALOG_INTERFACES_IPV4}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address.
function show_ipv6() {
  
  declare -a INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))
declare -a IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2 | awk '{print toupper($0)}'))  
	echo -e "${DIALOG_INTERFACES_IPV6}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info.
function show_all() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))
  declare -a IPV4_ARRAY=($(ip addr show | grep -w inet  | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
  declare -a IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2 | awk '{print toupper($0)}'))
  
	echo -e "${DIALOG_ALL}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}' | awk '{print toupper($0)}')
    printf " %-14s%-20s%-18s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces and their gateway.
function show_gateway() {
  
  local GATEWAY
  
  declare -a ONLINE_INTERFACES_ARRAY=($(ip route | grep default | awk '{print $5}'))
  
  echo -e "${DIALOG_INTERFACES_GATEWAY}"
  for i in "${!ONLINE_INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(ip route | grep "${ONLINE_INTERFACES_ARRAY[i]}" | grep ^default | awk '{print $3}')
    printf " %-14s%s\n" "${ONLINE_INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done
  exit
}

# Prints help message.
function usage() {
  
	echo    "usage: ship [OPTION] or ship [OPTION] <ARGUMENT>"
  echo    " basic operations:"
	echo -e "  ${GREEN}ship -4 ${NORMAL}, ${GREEN}--ipv4 ${NORMAL}          shows active interfaces with their IPv4 address"
	echo -e "  ${GREEN}ship -6 ${NORMAL}, ${GREEN}--ipv6 ${NORMAL}          shows active interfaces with their IPv6 address"
	echo -e "  ${GREEN}ship -a ${NORMAL}, ${GREEN}--all ${NORMAL}           shows all basic info"
	echo -e "  ${GREEN}ship -g ${NORMAL}, ${GREEN}--gateway ${NORMAL}       shows the gateway of online interfaces"
	echo -e "  ${GREEN}ship -h ${NORMAL}, ${GREEN}--help ${NORMAL}          shows this help message"
	echo -e "  ${GREEN}ship -i ${NORMAL}, ${GREEN}--interfaces ${NORMAL}    shows active interfaces"
  echo -e "  ${GREEN}ship -m ${NORMAL}, ${GREEN}--mac ${NORMAL}           shows active interfaces with their MAC address"
  echo -e "  ${GREEN}ship -v ${NORMAL}, ${GREEN}--version ${NORMAL}       shows the version of script"
	echo -e "  ${GREEN}ship --cidr-4${NORMAL}, ${GREEN}--cidr-ipv4 ${NORMAL}shows active interfaces with their IPv4 address and CIDR"
	echo -e "  ${GREEN}ship --cidr-6${NORMAL}, ${GREEN}--cidr-ipv6 ${NORMAL}shows active interfaces with their IPv6 address and CIDR"
	echo -e "  ${GREEN}ship --cidr-a${NORMAL}, ${GREEN}--cidr-all ${NORMAL} shows all basic info and CIDR"
	echo
	echo    " miscellaneous operations:"
  echo -e "  ${GREEN}ship -A ${NORMAL}, ${GREEN}--arp ${NORMAL}           shows ARP/neighbor cache"
  echo -e "  ${GREEN}ship -B ${NORMAL}, ${GREEN}--bandwidth ${NORMAL}     shows connection bandwidth to different locations"
  echo -e "  ${GREEN}ship -C ${NORMAL}, ${GREEN}--check ${NORMAL}<>       shows results of scans for malicious activities of a URL"
  echo -e "  ${GREEN}ship -F ${NORMAL}, ${GREEN}--find ${NORMAL}<>        shows the external IP address of {USER|DOMAIN}"
  echo -e "  ${GREEN}ship -H ${NORMAL}, ${GREEN}--hosts ${NORMAL}         shows active hosts on network"
  echo -e "  ${RED}ship -HM${NORMAL}, ${RED}--hosts-mac ${NORMAL}     shows active hosts on network with their MAC address"
  echo -e "  ${GREEN}ship -L ${NORMAL}, ${GREEN}--location ${NORMAL}<>    shows location info of {USER|DOMAIN}"
  echo -e "  ${RED}ship -P ${NORMAL}, ${RED}--port ${NORMAL}<>        shows the quantity of connections to {PORT} per IP"
  echo -e "  ${GREEN}ship -R ${NORMAL}, ${GREEN}--route ${NORMAL}<>       shows the path to a network host {IPv4|DOMAIN}"
  echo -e "  ${GREEN}ship -R6${NORMAL}, ${GREEN}--route-ipv6 ${NORMAL}<>  shows the path to a network host {IPv6|DOMAIN}"
	echo -e "  ${GREEN}ship -S ${NORMAL}, ${GREEN}--speed ${NORMAL}         shows the download and upload speed in kB/s"
	echo -e "  ${GREEN}ship -T ${NORMAL}, ${GREEN}--time ${NORMAL}<>        shows the average RTT to {IPv4|DOMAIN}"
	echo -e "  ${GREEN}ship -T6${NORMAL}, ${GREEN}--time-ipv6 ${NORMAL}<>   shows the average RTT to {IPv6|DOMAIN}"
  echo
  echo -e "Commands shown in ${RED}RED${NORMAL} require root privileges"
  exit
}

# Prints active network interfaces.
function show_interfaces() {
  
  declare -a INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))
  
	echo -e "${DIALOG_INTERFACES}"
  printf " %s\n" "${INTERFACES_ARRAY[@]}"
  exit
}

# Prints active network interfaces with their MAC address.
function show_mac() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))
  
	echo -e "${DIALOG_INTERFACES_MAC}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}' | awk '{print toupper($0)}')
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
  done
  exit
}

# Prints script's version and author's info.
function show_version() {
  
  echo
	echo    "         _~"
	echo -e "      _~ )_)_~          Author .: ${GREEN}${AUTHOR}${NORMAL}"
	echo -e "      )_))_))_)		Mail ...: ${GREEN}${GMAIL}${NORMAL}"
	echo -e "      ${ORANGE}_!__!__!_${NORMAL}		Github .: ${GREEN}${GITHUB}${NORMAL}"
	echo -e "      ${ORANGE}\_______/${NORMAL}         Version : ${GREEN}${VERSION}${NORMAL}"
	echo -e "  ${CYAN}~~~~~~~~~~~~~~~~~${NORMAL}"
}

# Prints active network interfaces with their IPv4 address and CIDR suffix.
function show_ipv4_cidr() {

  declare -a INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))
  declare -a IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | tail -n +2))
  
	echo -e "${DIALOG_INTERFACES_IPV4_CIDR}"
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address and CIDR suffix.
function show_ipv6_cidr() {
  
  declare -a INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))
  declare -a IPV6_CIDR_ARRAY=($(ip -6 addr | grep inet6 | awk -F '[ \t]+|' '{print $3}' | grep -v ^::1 | grep -v ^fe80 | awk '{print toupper($0)}'))
  
	echo -e "${DIALOG_INTERFACES_IPV6_CIDR}"
  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    printf " %-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info and CIDR suffix.
function show_all_cidr() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip addr show | grep -w inet | grep -v "${LOOPBACK}" | awk -F " " '{print $NF}'))
  declare -a IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet  | awk '{print $2}' | tail -n +2))
  declare -a IPV6_CIDR_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | tail -n +2 | awk '{print toupper($0)}'))
  
	echo -e "${DIALOG_ALL_CIDR}"
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(ip link show "${INTERFACES_ARRAY[i]}" | grep link | awk '{print $2}' | awk '{print toupper($0)}')
    printf " %-14s%-20s%-21s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}

################## Miscellaneous s Section  ####################

# Shows arp cache table.
function show_arp_cache() {
  
  local FILENAME
  
  FILENAME="ARP_CACHE"
  check_directory_or_touch_file "${FILENAME}"
  
  ip neigh | egrep -i 'permanent|noarp|stale|reachable|incomplete|delay|probe' | \
  grep -vi 'router' | \
  awk '{printf (" %-18s%-20s%s\n", $1, $5, $6)}' | awk '{print toupper($0)}' |  sort -V  >> "${TMP}/${FILENAME}"
  echo -e "${DIALOG_IPV4_MAC_STATE}"
  cat < "${TMP}/${FILENAME}" | sort -V
  mr_proper
}

# Prints bandwidth from different locations
function show_bandwidth() {

  local HTTP_CODE
  local DOWNLOAD
  
  echo -ne "Checking ${GREEN}${CDN_TEST}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${CDN_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    clear_line
    echo -ne "Downloading from ${GREEN}${CDN_TEST}${NORMAL}..."
    DOWNLOAD=$(wget -O /dev/null --report-speed=bits "${CDN_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    printf " %-16s${GREEN}%s${NORMAL}\n" "Cachefly" "${DOWNLOAD}"
  else
    clear_line
	  error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
  
  sleep 1.5
  
  echo -ne "Checking ${GREEN}${UK_TEST}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${UK_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    clear_line
    echo -ne "Downloading from ${GREEN}${UK_TEST}${NORMAL}..."
    DOWNLOAD=$(wget -O /dev/null --report-speed=bits "${UK_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    printf " %-16s${GREEN}%s${NORMAL}\n" "UK" "${DOWNLOAD}"
  else
    clear_line
	  error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
  
  sleep 1.5
  
  echo -ne "Checking ${GREEN}${AUSTRALIA_TEST}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${AUSTRALIA_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    clear_line
    echo -ne "Downloading from ${GREEN}${AUSTRALIA_TEST}${NORMAL}..."
    DOWNLOAD=$(wget -O /dev/null --report-speed=bits "${AUSTRALIA_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    printf " %-16s${GREEN}%s${NORMAL}\n" "Australia" "${DOWNLOAD}"
  else
    clear_line
	  error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
  
  sleep 1.5
  
  echo -ne "Checking ${GREEN}${USA_TEST}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${USA_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    clear_line
    echo -ne "Downloading from ${GREEN}${USA_TEST}${NORMAL}..."
    DOWNLOAD=$(wget -O /dev/null --report-speed=bits "${USA_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    printf " %-16s${GREEN}%s${NORMAL}\n" "USA" "${DOWNLOAD}"
  else
    clear_line
	  error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
  
  sleep 1.5
  
  echo -ne "Checking ${GREEN}${SINGAPORE_TEST}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${SINGAPORE_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    clear_line
    echo -ne "Downloading from ${GREEN}${SINGAPORE_TEST}${NORMAL}..."
    DOWNLOAD=$(wget -O /dev/null --report-speed=bits "${SINGAPORE_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    printf " %-16s${GREEN}%s${NORMAL}\n" "Singapore" "${DOWNLOAD}"
  else
    clear_line
	  error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
  
  sleep 1.5
  
  echo -ne "Checking ${GREEN}${NETHERLANDS_TEST}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${NETHERLANDS_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    clear_line
    echo -ne "Downloading from ${GREEN}${NETHERLANDS_TEST}${NORMAL}..."
    DOWNLOAD=$(wget -O /dev/null --report-speed=bits "${NETHERLANDS_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    printf " %-16s${GREEN}%s${NORMAL}\n" "Netherlands" "${DOWNLOAD}"
  else
    clear_line
	  error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
  
  sleep 1.5
  
  echo -ne "Checking ${GREEN}${FRANCE_TEST}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${FRANCE_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    clear_line
    echo -ne "Downloading from ${GREEN}${FRANCE_TEST}${NORMAL}..."
    DOWNLOAD=$(wget -O /dev/null --report-speed=bits "${FRANCE_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    printf " %-16s${GREEN}%s${NORMAL}\n" "France" "${DOWNLOAD}"
  else
    clear_line
	  error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
  
  sleep 1.5
  
  echo -ne "Checking ${GREEN}${GREECE_TEST}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${GREECE_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    clear_line
    echo -ne "Downloading from ${GREEN}${GREECE_TEST}${NORMAL}..."
    DOWNLOAD=$(wget -O /dev/null --report-speed=bits "${GREECE_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    printf " %-16s${GREEN}%s${NORMAL}\n" "Greece" "${DOWNLOAD}"
  else
    clear_line
	  error_exit "${DIALOG_SERVER_IS_DOWN}"
	fi
}

# Prints the public IP address of a website or server. If $1 is empty prints user's public IP, if not, $1 should be example.com.
function show_ip_from() {
  
  local HTTP_CODE
  local FILENAME
  local IP
  
  if [[ -z "$1" ]]; then
    echo -ne "Checking ${GREEN}${IPINFO}${NORMAL}..."
    HTTP_CODE=$(wget --spider -S "${IPINFO}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    if [[ "${HTTP_CODE}" -eq "200" ]]; then
      clear_line
      echo -ne "Grabbing IP..."
      IP=$(wget "${IPINFO}/ip" -qO -)
      clear_line
      echo -e "${DIALOG_IPV4}"
		  echo " ${IP}"
      exit
	  else
      clear_line
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  else
    echo -ne "Checking ${GREEN}$1${NORMAL}..."
    HTTP_CODE=$(wget --spider -S "$1" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    if [[ "${HTTP_CODE}" -eq "200" ]]; then
      clear_line
      FILENAME="IPS_FROM"
      check_directory_or_touch_file "${FILENAME}"
      INPUT=$(echo "$1" | sed 's/^http\(\|s\):\/\///g' | cut -f 1 -d "/")
      echo -ne "Pinging ${GREEN}$1${NORMAL}..."
      for i in {1..15}; do
        echo -n " "
        ping -4 -c 1 -i 0.2 -w 5 "${INPUT}" 2>"${NULL}" | awk -F '[()]' '/PING/{print $2}' >> "${TMP}/${FILENAME}" &
      done
      handle_jobs
      clear_line
      sed -i 's/^/ /' "${TMP}/${FILENAME}"
      echo -e "${DIALOG_IPV4}"
      cat < "${TMP}/${FILENAME}" | sort -V | uniq
      mr_proper
      exit
    else
      clear_line
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  fi
}

# Checks domain for malicious activities and prints if it is safe or not.
function show_malicious_results() {
  
  if [[ -z "$1" ]] || echo "$1" | egrep "([0-9]{1,3}[\.]){3}[0-9]{1,3}"; then
    check_command "-C" "--check" "example.com"
  fi
  
  local HTTP_CODE
  local FILENAME
  local FILTERED_URL
  local IP
  local RESULT
  
  FILTERED_URL=$(echo "$1" | sed 's/^http\(\|s\):\/\///g' | sed 's/www.//' | cut -f 1 -d "/")
  
  echo -ne "Checking ${GREEN}${FILTERED_URL}${NORMAL}..."
  HTTP_CODE=$(wget --spider -S "${FILTERED_URL}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq "200" ]]; then
    FILENAME="SCANNED_URL"
    check_directory_or_touch_file "${FILENAME}"
    wget --quiet "${SCAN}${FILTERED_URL}" -O "${TMP}/${FILENAME}"
    grep -i "safety\ reputation" "${TMP}/${FILENAME}" | \
    sed -e 's/<[^>]*>//g' | \
    sed -e 's/[A-Za-z]*//g' | \
    cut -f 1 -d "/" | \
    sed -e 's/^[ \t]*//' > "${TMP}/PARSED_URL_DATA"
    RESULT=$(cat ${TMP}/PARSED_URL_DATA)
    clear_line
    if [[ "${RESULT}" -eq "0" ]]; then
      echo -e "${FILTERED_URL} is ${GREEN}clean${NORMAL}"
    elif [[ "${RESULT}" -ge "1" ]] && [[ "${RESULT}" -le "3" ]]; then
      echo -e "${FILTERED_URL} is identified by $(cat ${TMP}/PARSED_URL_DATA) scanning engine/s"
      echo -e "${CYAN}${SCAN}${FILTERED_URL}${NORMAL}"
    elif [[ "${RESULT}" -ge "4" ]] && [[ "${RESULT}" -le "13" ]]; then
      echo -e "${ORANGE}${FILTERED_URL}${NORMAL} is identified by $(cat ${TMP}/PARSED_URL_DATA) scanning engine/s${NORMAL}"
      echo -e "${CYAN}${SCAN}${FILTERED_URL}${NORMAL}"
    elif [[ "${RESULT}" -ge "14" ]]; then
      echo -e "${RED}${FILTERED_URL}${NORMAL} is identified by $(cat ${TMP}/PARSED_URL_DATA) scanning engine/s${NORMAL}"
      echo -e "${CYAN}${SCAN}${FILTERED_URL}${NORMAL}"
    else
      error_exit
    fi
    mr_proper
    exit
  else
    clear_line
    error_exit "${DIALOG_SERVER_IS_DOWN}"
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
  echo -ne "Checking ${GREEN}${IPINFO}${NORMAL}..."
  if [[ ! "${HTTP_CODE_IPINFO}" -eq "200" ]]; then
    clear_line
    error_exit "${DIALOG_SERVER_IS_DOWN}"
  else
    clear_line
    if [[ ! -z "$1" ]]; then
      INPUT=$(echo "$1" | sed 's/^http\(\|s\):\/\///g' | cut -f 1 -d "/")
      echo -ne "Pinging ${GREEN}${INPUT}${NORMAL}..."
      IP=$(ping -4 -c 1 -w 5 "${INPUT}" 2>"${NULL}" | awk -F'[()]' '/PING/{print $2}' &)
      clear_line
      ZOOM="9"
      echo -ne "Grabbing ${GREEN}hostname${NORMAL}..."
      HOSTNAME=$(wget -qO - ${IPINFO}/"${IP}"/hostname &)
      clear_line
      echo -ne "Grabbing ${GREEN}city${NORMAL}..."
      CITY=$(wget -qO - ${IPINFO}/"${IP}"/city &)
      clear_line
      echo -ne "Grabbing ${GREEN}region${NORMAL}..."
      REGION=$(wget -qO - ${IPINFO}/"${IP}"/region &)
      clear_line
      echo -ne "Grabbing ${GREEN}country${NORMAL}..."
      COUNTRY=$(wget -qO - ${IPINFO}/"${IP}"/country &)
      clear_line
      echo -ne "Grabbing ${GREEN}location${NORMAL}..."
      LOC=$(wget -qO - ${IPINFO}/"${IP}"/loc &)
      clear_line
      echo -ne "Grabbing ${GREEN}organization${NORMAL}..."
      ORG=$(wget -qO - ${IPINFO}/"${IP}"/org &)
      clear_line
      handle_jobs
      # pass data one by one to print_location_info()
      print_location_info "${IP}" "${HOSTNAME}" "${CITY}" "${REGION}" "${COUNTRY}" "${LOC}" "${ORG}"
      MAP_LOC="https://maps.googleapis.com/maps/api/staticmap?center=${LOC}&zoom=${ZOOM}&size=640x640&sensor=false"
      echo
      echo -e "${MAP_LOC}"
      exit
    else
      ZOOM="12"
      echo -ne "Grabbing IP..."
      IP=$(wget -qO - ${IPINFO}/ip &)
      clear_line
      echo -ne "Grabbing ${GREEN}hostname${NORMAL}..."
      HOSTNAME=$(wget -qO - ${IPINFO}/"${IP}"/hostname &)
      clear_line
      echo -ne "Grabbing ${GREEN}city${NORMAL}..."
      CITY=$(wget -qO - ${IPINFO}/"${IP}"/city &)
      clear_line
      echo -ne "Grabbing ${GREEN}region${NORMAL}..."
      REGION=$(wget -qO - ${IPINFO}/"${IP}"/region &)
      clear_line
      echo -ne "Grabbing ${GREEN}country${NORMAL}..."
      COUNTRY=$(wget -qO - ${IPINFO}/"${IP}"/country &)
      clear_line
      echo -ne "Grabbing ${GREEN}location${NORMAL}..."
      LOC=$(wget -qO - ${IPINFO}/"${IP}"/loc &)
      clear_line
      echo -ne "Grabbing ${GREEN}organization${NORMAL}..."
      ORG=$(wget -qO - ${IPINFO}/"${IP}"/org &)
      clear_line
      handle_jobs
      # pass data one by one to print_location_info()
      print_location_info "${IP}" "${HOSTNAME}" "${CITY}" "${REGION}" "${COUNTRY}" "${LOC}" "${ORG}"
      MAP_LOC="https://maps.googleapis.com/maps/api/staticmap?center=${LOC}&zoom=${ZOOM}&size=640x640&sensor=false"
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
    ss -np | grep ":${PORT}" | egrep "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | awk '{print $6}' | cut -d : -f 1 | uniq -c
    sleep 3
  done
}

# Prints hops to a destination. $1=--ipv4|--ipv6, $2=destination.
function show_next_hops() {
  
  local HTTP_CODE
  local FILTERED_INPUT
  local FILENAME
  local HAS_IPV6
  
  if [[ -z "$2" ]]; then
    error_exit "${DIALOG_NO_ARGUMENTS}"
  else
    FILTERED_INPUT=$(echo "$2" | sed 's/^http\(\|s\):\/\///g' | cut -f 1 -d "/")
    FILENAME="NEXT_HOPS"
    check_directory_or_touch_file "${FILENAME}"
    case "$1" in
      "--ipv4")
        echo -ne "Checking ${GREEN}$2${NORMAL}..."
        HTTP_CODE=$(wget --spider -S "${FILTERED_INPUT}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
        if [[ "${HTTP_CODE}" -eq "200" ]]; then
          clear_line
          echo -ne "Tracing path to ${GREEN}${FILTERED_INPUT}${NORMAL}..."
          tracepath -n "${FILTERED_INPUT}" | awk '{print $2}' | egrep -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >> "${TMP}/${FILENAME}"
          clear_line
          sed -i 's/^/ /' "${TMP}/${FILENAME}"
          echo -e "${DIALOG_IPV4}"
          cat < "${TMP}/${FILENAME}" | uniq
          mr_proper
          exit
        else
          clear_line
		      error_exit "${DIALOG_SERVER_IS_DOWN}"
        fi
      ;;
      "--ipv6")
        HAS_IPV6=$(cat < /proc/modules | grep -o ipv6)
        if [[ "${HAS_IPV6}" ]]; then
          echo -ne "Checking ${GREEN}$2${NORMAL}..."
          HTTP_CODE=$(wget --spider -S "${FILTERED_INPUT}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
          if [[ "${HTTP_CODE}" -eq "200" ]]; then
            clear_line
            echo -ne "Tracing path to ${FILTERED_INPUT}..."
            tracepath6 -n "${FILTERED_INPUT}" | awk '{print $2}' | egrep -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >> "${TMP}/${FILENAME}"
            clear_line
            sed -i 's/^/ /' "${TMP}/${FILENAME}"
            echo -e "${DIALOG_IPV6}"
            cat < "${TMP}/${FILENAME}" | uniq
            mr_proper
            exit
          else
            clear_line
            error_exit "${DIALOG_SERVER_IS_DOWN}"
          fi
          exit
        else
          error_exit "IPv6 unavailable. ${DIALOG_ABORTING}"
        fi
      ;;
    esac
  fi  
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

# Prints avg rtt from a destination, if $1 is empty, it prints avg rtt from google.
function show_avg_ping() {

	local HTTP_CODE
  local FILTERED_URL
  local PING_4
  local PING_6
  local HAS_IPV6
  
  if [[ -z "$2" ]]; then
    case "$1" in
      "--ipv4")
        echo -ne "Playing ping pong with ${GREEN}Google${NORMAL}, please wait..."
        PING_4=$(ping -4 -i 0.5 -c 10 ${GOOGLE_DNS} | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
        clear_line
        echo -e "Average RTT: ${GREEN}${PING_4} ms${NORMAL}"
        exit
      ;;
      "--ipv6")
        HAS_IPV6=$(cat < /proc/modules | grep -o ipv6)
        if [[ "${HAS_IPV6}" ]]; then
          echo -ne " Playing ping pong with ${GREEN}Google${NORMAL}, please wait..."
          PING_6=$(ping -6 -i 0.5 -c 10 "${GOOGLE_DNS}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
          clear_line
          echo -e "Average RTT: ${GREEN}${PING_6} ms${NORMAL}"
          exit
        else
          error_exit "IPv6 unavailable. ${DIALOG_ABORTING}"
        fi
      ;;
    esac
  else
    FILTERED_URL=$(echo "$2" | sed 's/^http\(\|s\):\/\///g' | sed 's/www.//' | cut -f 1 -d "/")
    HTTP_CODE=$(wget --spider -S "${FILTERED_URL}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    if [[ "${HTTP_CODE}" -eq "200" ]]; then
      case "$1" in
        "--ipv4")
          echo -ne "Playing ping pong with ${GREEN}${FILTERED_URL}${NORMAL}, please wait..."
          PING_4=$(ping -4 -i 0.5 -c 10 "${FILTERED_URL}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
          clear_line
          echo -e "Average response time: ${GREEN}${PING_4} ms${NORMAL}"
          exit
        ;;
        "--ipv6")
          HAS_IPV6=$(cat < /proc/modules | grep -o ipv6)
          if [[ "${HAS_IPV6}" ]]; then
            echo -ne "Playing ping pong with ${GREEN}${FILTERED_URL}${NORMAL}, please wait..."
            PING_6=$(ping -6 -i 0.5 -c 10 "${FILTERED_URL}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
            clear_line
            echo -e "Average response time: ${GREEN}${PING_6} ms${NORMAL}"
            exit
          else
            error_exit "IPv6 unavailable. ${DIALOG_ABORTING}"
          fi
        ;;
      esac
    fi
  fi
}

# Scans live hosts on network and prints their IPv4 address with or without MAC address. ICMP and ARP.
function show_live_hosts() {
  
  local ONLINE_INTERFACE
  local NETWORK_IP
  local NETWORK_IP_CIDR
  local FILTERED_IP
  local FILENAME
  local FILENAME_TWO
  
  ONLINE_INTERFACE=$(ip route get "${GOOGLE_DNS}" | awk -F "dev " 'NR == 1 { split($2, a, " "); print a[1] }')
  NETWORK_IP=$(ip route | grep "${ONLINE_INTERFACE}" | grep src | awk '{print $1}' | cut -f 1 -d "/")
  NETWORK_IP_CIDR=$(ip route | grep "${ONLINE_INTERFACE}" | grep src | awk '{print $1}')
  FILTERED_IP=$(echo "${NETWORK_IP}" | awk 'BEGIN{FS=OFS="."} NF--')
  
  case "$1" in
    "--normal")
      FILENAME="IPV4_OF_PING"
      check_directory_or_touch_file "${FILENAME}"
      echo -ne "Pinging ${GREEN}${NETWORK_IP_CIDR}${NORMAL}, please wait..."
      for i in {1..254}; do
        ping "${FILTERED_IP}.${i}" -c 1 -w 5 >"${NULL}" &&
        echo " ${FILTERED_IP}.${i}" >> "${TMP}/${FILENAME}" &
      done
      handle_jobs
      clear_line
      echo -e "${DIALOG_IPV4}"
      cat < "${TMP}/${FILENAME}" | sort -V | uniq -u
      mr_proper
      exit
    ;;
    "--mac")
      mr_proper
      FILENAME="IPS_OF_ARPING"
      FILENAME_TWO="MACS_OF_ARPING"
      check_directory_or_touch_file "${FILENAME}"
      check_directory_or_touch_file "${FILENAME_TWO}"
      echo -ne "Arping ${GREEN}${NETWORK_IP_CIDR}${NORMAL}, please wait..."
      for i in {1..254}; do
        arping -I "${ONLINE_INTERFACE}" "${FILTERED_IP}.${i}" -c 1 2>"${NULL}" | tail -n +2 | head -n 1 | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' >> "${TMP}/${FILENAME}" &
        sleep 0.012
        arping -I "${ONLINE_INTERFACE}" "${FILTERED_IP}.${i}" -c 1 2>"${NULL}" | tail -n +2 | head -n 1 | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}'  >> "${TMP}/${FILENAME_TWO}" &
      done
      handle_jobs
      sed -i 's/^/ /' "${TMP}/${FILENAME}"
      clear_line
      echo -e "${DIALOG_IPV4_MAC}"
      pr -mtw 37 "${TMP}/${FILENAME}" "${TMP}/${FILENAME_TWO}"
      mr_proper
      exit
    ;;
  esac
}

################ In-function functions section ^-^ #####################
###################### Printing functions ##############################

# Prints show_location_info() data.
function print_location_info() {
  
  echo
  echo -e " ${GREEN}IP${RED}\t\t$1"
  echo -e " ${GREEN}Hostname${NORMAL}\t$2"
  echo -e " ${GREEN}City${NORMAL}\t\t$3"
  echo -e " ${GREEN}Region${NORMAL}\t\t$4"
  echo -e " ${GREEN}Country${NORMAL}\t$5"
  echo -e " ${GREEN}Location${RED}\t$6"
  echo -e " ${GREEN}Organization${NORMAL}\t$7"
}

# Prints a list of most common ports with protocols.
function print_port_protocol_list() {

  declare -a PORTS_ARRAY=("20-21" "22" "23" "25" "53" "67-68" "69" "80" "110" \
               "123" "137-139" "143" "161-162" "179" "389" "443" "636" \
               "989-990")
  declare -a PORTS_TCP_UDP_ARRAY=("TCP" "TCP" "TCP" "TCP" "TCP/UDP" "UDP" "UDP" \
                       "TCP" "TCP" "UDP" "TCP/UDP" "TCP" "TCP/UDP" "TCP"\
                       "TCP/UDP" "TCP" "TCP/UDP" "TCP")
  declare -a PORTS_PROTOCOL_ARRAY=("FTP" "SSH" "Telnet" "SMTP" "DNS" "DHCP" "TFTP" \
                        "HTTP" "POPv3" "NTP" "NetBIOS" "IMAP" "SNMP" \
                        "BGP" "LDAP" "HTTPS" "LDAPS" "FTP over TLS/SSL")
  
  echo -e  "${DIALOG_PORTS}"
  for i in "${!PORTS_ARRAY[@]}"; do
    printf " %-20s%-11s%s\n" "${PORTS_PROTOCOL_ARRAY[i]}" "${PORTS_TCP_UDP_ARRAY[i]}" "${PORTS_ARRAY[i]}"
  done
  exit
}

# Clears previous line
function clear_line() {
  
  printf "\r\033[K"
}

############################ Handlers ##################################

# Checks network connection (local or internet).
function check_connectivity() {
  
  case "$1" in
    "--local") ip route | grep "^default" >"${NULL}" || error_exit "${DIALOG_NO_LOCAL_CONNECTION}" ;;
    "--internet") ping -q -c 1 -W 1 "${GOOGLE_DNS}" >"${NULL}" || error_exit "${DIALOG_NO_INTERNET}" ;;
  esac
}

# CURRENTLY NOT USED. Checks tool's existance in system.
function check_for_missing_tool() {
  
  hash "$1" 2>"${NULL}" || {
    
    error_exit "Install ${ORANGE}$1${NORMAL} and then try again. ${DIALOG_ABORTING}"
  }
}

# e.g.(-f example.com). Checks if "example.com" is empty. $1 is the option, $2 is the alternative option and $3 is the passed parameter.
function check_command() {

  error_exit "${GREEN}ship $1 ${NORMAL}or ${GREEN}ship $2 ${NORMAL}$3"
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
  
  if [[ "$(id -u)" -eq "0" ]]; then
    chmod -R a+w "${TMP}"
  fi
}

# Checks for root privileges.
function check_root_permissions() {
  
  if [[ "$(id -u)" -ne "0" ]]; then
    error_exit "${GREEN}ship${NORMAL} requires ${RED}root${NORMAL} privileges for this action."
  fi
}

# Deletes every file that is created by this script. Usually in /tmp
function mr_proper() {
  
  rm -rf "${TMP}" 2>"${NULL}"
}

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

# Background tasks' handeler.
function handle_jobs() {
  
  local JOB
  
  for JOB in $(jobs -p); do
      wait "${JOB}"
  done
}

###################### Initializes script. #############################
function __init__() {
  
  if [[ -z "$1" ]]; then error_exit "${DIALOG_ERROR}"; fi
  
  check_directory_or_touch_file
  
  while :
  do
    case "$1" in
      "-4"|"--ipv4") check_connectivity "--local"; show_ipv4; break ;;
      "-6"|"--ipv6") check_connectivity "--local"; show_ipv6; break ;;
      "-A"|"--arp") check_connectivity "--local"; show_arp_cache; break ;;
      "-a"|"--all") check_connectivity "--local"; show_all; break ;;
      "-B"|"--bandwidth") check_connectivity "--internet"; show_bandwidth; break ;;
      "-C"|"--check") check_connectivity "--internet"; show_malicious_results "$2"; shift 2; break ;;
      "-F"|"--find") check_connectivity "--internet"; show_ip_from "$2"; shift 2; break ;;
      "-g"|"--gateway") check_connectivity "--local"; show_gateway; break ;;
      "-H"|"--hosts") check_connectivity "--internet"; show_live_hosts --normal; break ;;
      "-HM"|"--hosts-mac") check_root_permissions; check_connectivity "--internet"; show_live_hosts --mac; break ;;
      "-h"|"--help") usage; break ;;
      "-i"|"--interfaces") check_connectivity "--local"; show_interfaces; break ;;
      "-L"|"--location") check_connectivity "--internet"; show_location_info "$2"; shift 2; break ;;
      "-P"|"--port") check_root_permissions; check_connectivity "--internet"; show_port_connections "$2"; shift 2; break ;;
      "-R"|"--route") check_connectivity "--internet"; show_next_hops --ipv4 "$2"; shift 2; break ;;
      "-R6"|"--route-ipv6") check_connectivity "--internet"; show_next_hops --ipv6 "$2"; shift 2; break ;;
      "-m"|"--mac") check_connectivity "--local"; show_mac; break ;;
      "-S"|"--speed") check_connectivity "--internet"; show_speed; break ;;
      "-T"|"--time") check_connectivity "--internet"; show_avg_ping --ipv4 "$2"; shift 2; break ;;
      "-T6"|"--time-ipv6") check_connectivity "--internet"; show_avg_ping --ipv6 "$2"; shift 2; break ;;
      "-v"|"--version") show_version; break ;;
      "--cidr-4"|"--cidr-ipv4") check_connectivity "--local"; show_ipv4_cidr; break ;;
      "--cidr-6"|"--cidr-ipv6") check_connectivity "--local"; show_ipv6_cidr; break ;;
      "--cidr-a"|"--cidr-all") check_connectivity "--local"; show_all_cidr; break ;;
      *) error_exit "${DIALOG_ERROR}" "$1"; break ;;
    esac
  done
}

__init__ "$1" "$2"
