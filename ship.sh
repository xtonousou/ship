#!/bin/bash
#### Description......: Show IPv4, IPv6 and MAC addresses, and many more.
#### Written by.......: Sotirios Roussis (aka. xtonousou) - xtonousou@gmail.com on 10-2016
#### Known limitations: ipinfo.io offers free 1,000 daily requests. (ship -F, -L)

### INFO
AUTHOR="Sotirios Roussis"
AUTHOR_NICKNAME="xtonousou"
GMAIL="${AUTHOR_NICKNAME}@gmail.com"
GITHUB="https://github.com/${AUTHOR_NICKNAME}"
VERSION="1.9"

### Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
ORANGE="\033[1;33m"
NORMAL="\e[1;0m"

### Locations
TMP="/tmp/ship"
NULL="/dev/null"
GOOGLE_DNS="8.8.8.8"
IPINFO="ipinfo.io"
CDN_TEST="cachefly.cachefly.net/10mb.test"
SINGAPORE_TEST="phantom.starserverspeedtest.com/test10.zip"
USA_TEST="mirror.us.leaseweb.net/speedtest/10mb.bin"
AUSTRALIA_TEST="mirror.filearena.net/pub/speed/SpeedTest_16MB.dat"
NETHERLANDS_TEST="mirror.nl.leaseweb.net/speedtest/10mb.bin"
FRANCE_TEST="proof.ovh.net/files/10Mb.dat"
UK_TEST="download.thinkbroadband.com/10MB.zip"
GREECE_TEST="speedtest.ftp.otenet.gr/files/test10Mb.db"
SCAN="urlvoid.com/scan/"

### Dialogs
DIALOG_PRESS_CTRL_C="Press [CTRL+C] to stop"
DIALOG_ERROR="Try ${GREEN}ship -h${NORMAL} or ${GREEN}ship --help${NORMAL} for more information."
DIALOG_ABORTING="${RED}Aborting${NORMAL}."
DIALOG_NO_INTERNET="Internet connection unavailable. ${DIALOG_ABORTING}"
DIALOG_NO_LOCAL_CONNECTION="Local connection unavailable. ${DIALOG_ABORTING}"
DIALOG_SERVER_IS_DOWN="Destination is unreachable. Server may be down or has connection issues. ${DIALOG_ABORTING}"
DIALOG_NOT_A_NUMBER="Option should be integer. ${DIALOG_ABORTING}"
DIALOG_NO_ARGUMENTS="No arguments. ${DIALOG_ABORTING}"

### Regexes
REGEX_MAC="([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}"
REGEX_IPV4="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"
REGEX_IPV6="([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|"
REGEX_IPV6="${REGEX_IPV6}([0-9a-fA-F]{1,4}:){1,7}:|"
REGEX_IPV6="${REGEX_IPV6}([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|"
REGEX_IPV6="${REGEX_IPV6}([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|"
REGEX_IPV6="${REGEX_IPV6}([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|"
REGEX_IPV6="${REGEX_IPV6}([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|"
REGEX_IPV6="${REGEX_IPV6}([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|"
REGEX_IPV6="${REGEX_IPV6}[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|"     
REGEX_IPV6="${REGEX_IPV6}:((:[0-9a-fA-F]{1,4}){1,7}|:)|"
REGEX_IPV6="${REGEX_IPV6}fe08:(:[0-9a-fA-F]{1,4}){2,2}%[0-9a-zA-Z]{1,}|" # (link-local IPv6 addresses with zone index)
REGEX_IPV6="${REGEX_IPV6}::(ffff(:0{1,4}){0,1}:){0,1}${REGEX_IPV4}|"     # (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
REGEX_IPV6="${REGEX_IPV6}([0-9a-fA-F]{1,4}:){1,4}:${REGEX_IPV4}"         # (IPv4-Embedded IPv6 Address)

########################## SOF MAIN FUNCTIONS ##########################

# Prints help message.
function show_usage() {
  
  echo    "usage: ship [OPTION] or ship [OPTION] <ARGUMENT>"
  echo    " basic operations:"
  echo -e "  ${GREEN}ship -4 ${NORMAL}, ${GREEN}--ipv4 ${NORMAL}          shows active interfaces with their IPv4 address"
  echo -e "  ${GREEN}ship -6 ${NORMAL}, ${GREEN}--ipv6 ${NORMAL}          shows active interfaces with their IPv6 address"
  echo -e "  ${GREEN}ship -a ${NORMAL}, ${GREEN}--all ${NORMAL}           shows all basic info"
  echo -e "  ${GREEN}ship -d ${NORMAL}, ${GREEN}--driver ${NORMAL}        shows each active interface's driver"
  echo -e "  ${GREEN}ship -f ${NORMAL}, ${GREEN}--find ${NORMAL}<>        shows all valid IPv4, IPv6 and MAC addresses in {FILE}"
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
  echo -e "  ${GREEN}ship -C ${NORMAL}, ${GREEN}--check ${NORMAL}<>       shows results of scans for malicious activities of {URL}"
  echo -e "  ${GREEN}ship -E ${NORMAL}, ${GREEN}--external ${NORMAL}<>    shows the external IP address of {USER|DOMAIN}"
  echo -e "  ${GREEN}ship -H ${NORMAL}, ${GREEN}--hosts ${NORMAL}         shows active hosts on network"
  echo -e "  ${GREEN}ship -HM${NORMAL}, ${GREEN}--hosts-mac ${NORMAL}     shows active hosts on network with their MAC address"
  echo -e "  ${GREEN}ship -L ${NORMAL}, ${GREEN}--location ${NORMAL}<>    shows location info of {USER|DOMAIN}"
  echo -e "  ${RED}ship -P ${NORMAL}, ${RED}--port ${NORMAL}<>        shows the quantity of connections to {PORT} per IP"
  echo -e "  ${GREEN}ship -R ${NORMAL}, ${GREEN}--route ${NORMAL}<>       shows the path to a network host {IPV4|DOMAIN}"
  echo -e "  ${GREEN}ship -R6${NORMAL}, ${GREEN}--route-ipv6 ${NORMAL}<>  shows the path to a network host {IPV6|DOMAIN}"
  echo -e "  ${GREEN}ship -S ${NORMAL}, ${GREEN}--speed ${NORMAL}         shows the download and upload speed in kB/s"
  echo -e "  ${GREEN}ship -T ${NORMAL}, ${GREEN}--time ${NORMAL}<>        shows the average RTT to {IPV4|DOMAIN}"
  echo -e "  ${GREEN}ship -T6${NORMAL}, ${GREEN}--time-ipv6 ${NORMAL}<>   shows the average RTT to {IPV6|DOMAIN}"
  echo -e "  ${GREEN}ship -U ${NORMAL}, ${GREEN}--url ${NORMAL}<>         shows all valid IPv4, IPv6 and MAC addresses of {URL}"
  echo
  echo -e "Commands shown in ${RED}RED${NORMAL} require root privileges"
  exit
}

# Prints active network interfaces with their IPv4 address.
function show_ipv4() {
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV4_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address.
function show_ipv6() {
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2 | awk '{print toupper($0)}'))  

  for i in "${!INTERFACES_ARRAY[@]}"; do
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info.
function show_all() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV4_ARRAY=($(ip addr show | grep -w inet  | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
  declare -a IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2 | awk '{print toupper($0)}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(cat < "/sys/class/net/${INTERFACES_ARRAY[i]}/address" | awk '{print toupper($0)}' 2>"${NULL}")
    printf "%-14s%-20s%-18s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
  exit
}

# Prints the driver used of active interface.
function show_driver() {
  
  local DRIVER_OF
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    if [[ -f "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent" ]]; then
      DRIVER_OF=$(cat < "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent" | grep ^"DRIVER" | awk -F '=' '{print $2}')
    else
      DRIVER_OF=$(cat < "/sys/class/net/${INTERFACES_ARRAY[i]}/device/uevent" | grep ^"DRIVER" | awk -F '=' '{print $2}')
    fi
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" 
  done
}

# Prints all IPv4 or IPv6 addresses extracted from a file.
function show_ips_from_file() {
    
  if [[ -z "$1" ]]; then
    error_exit "No file was specified. ${DIALOG_ABORTING}"
  fi
  
  local FILENAME_IPV4
  local FILENAME_IPV6
  local FILENAME_MAC

  FILENAME_IPV4="IPV4_OF_FILE"
  FILENAME_IPV6="IPV6_OF_FILE"
  FILENAME_MAC="MAC_OF_FILE"
  
  check_directory_or_touch_file "${FILENAME_IPV4}"
  check_directory_or_touch_file "${FILENAME_IPV6}"
  check_directory_or_touch_file "${FILENAME_MAC}"
  
  if [[ ! -f "$1" ]]; then
    error_exit "No such file. ${DIALOG_ABORTING}"
  fi
  
  grep -E -o "${REGEX_IPV4}" "$1" | sort -Vu >> "${TMP}/${FILENAME_IPV4}" &
  grep -E -o "${REGEX_IPV6}" "$1" | sort -Vu >> "${TMP}/${FILENAME_IPV6}" &
  grep -E -o "${REGEX_MAC}"  "$1" | sort -Vu >> "${TMP}/${FILENAME_MAC}"  &
  
  handle_jobs
  
  if [[ ! -s "${TMP}/${FILENAME_IPV4}" ]] && [[ ! -s "${TMP}/${FILENAME_IPV6}" ]] && [[ ! -s "${TMP}/${FILENAME_MAC}" ]]; then
  # if no valid addresses found, exit.
    error_exit "No valid IPv4, IPv6 or MAC addresses found. ${DIALOG_ABORTING}"
  elif [[ -s "${TMP}/${FILENAME_MAC}" ]] && [[ -s "${TMP}/${FILENAME_IPV4}" ]] && [[ -s "${TMP}/${FILENAME_IPV6}" ]]; then
  # if there are valid IPv4, IPv6 and MAC addresses...  
    paste "${TMP}/${FILENAME_IPV4}" "${TMP}/${FILENAME_IPV6}" "${TMP}/${FILENAME_MAC}" | awk -F '\t' '{printf("%-16s%-40s%s\n", $1, $2, $3)}'
  elif [[ ! -s "${TMP}/${FILENAME_MAC}" ]] && [[ -s "${TMP}/${FILENAME_IPV4}" ]] && [[ -s "${TMP}/${FILENAME_IPV6}" ]]; then
  # if there are only                                                  ^^^^addresses                         ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV4}" "${TMP}/${FILENAME_IPV6}" | awk -F '\t' '{printf("%-16s%s\n", $1, $2)}' 
  elif [[ ! -s "${TMP}/${FILENAME_IPV4}" ]] && [[ -s "${TMP}/${FILENAME_MAC}" ]] && [[ -s "${TMP}/${FILENAME_IPV6}" ]]; then 
  # if there are only                                                   ^^^addresses                         ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV6}" "${TMP}/${FILENAME_MAC}" | awk -F '\t' '{printf("%-40s%s\n", $1, $2)}'
  elif [[ ! -s "${TMP}/${FILENAME_IPV6}" ]] && [[ -s "${TMP}/${FILENAME_MAC}" ]] && [[ -s "${TMP}/${FILENAME_IPV4}" ]]; then 
  # if there are only                                                   ^^^addresses                         ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV4}" "${TMP}/${FILENAME_MAC}" | awk -F '\t' '{printf("%-16s%s\n", $1, $2)}'
  elif [[ ! -s "${TMP}/${FILENAME_MAC}" ]] && [[ ! -s "${TMP}/${FILENAME_IPV6}" ]] && [[ -s "${TMP}/${FILENAME_IPV4}" ]]; then 
  # if there are only                                                                                          ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV4}" | awk -F '\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${TMP}/${FILENAME_MAC}" ]] && [[ ! -s "${TMP}/${FILENAME_IPV4}" ]] && [[ -s "${TMP}/${FILENAME_IPV6}" ]]; then 
  # if there are only                                                                                          ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV6}" | awk -F '\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${TMP}/${FILENAME_IPV4}" ]] && [[ ! -s "${TMP}/${FILENAME_IPV6}" ]] && [[ -s "${TMP}/${FILENAME_MAC}" ]]; then 
  # if there are only                                                                                           ^^^addresses...
    paste "${TMP}/${FILENAME_MAC}" | awk -F '\t' '{printf("%s\n", $1)}'
  fi
  
  mr_proper
  exit
}

# Prints active network interfaces and their gateway.
function show_gateway() {
  
  local GATEWAY
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(ip route | grep "${INTERFACES_ARRAY[i]}" | grep ^default | awk '{print $3}')
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done
  exit
}

# Prints active network interfaces.
function show_interfaces() {
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))

  printf "%s\n" "${INTERFACES_ARRAY[@]}"
  exit
}

# Prints active network interfaces with their MAC address.
function show_mac() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(cat < "/sys/class/net/${INTERFACES_ARRAY[i]}/address" | awk '{print toupper($0)}' 2>"${NULL}")
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
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
  exit
}

# Prints active network interfaces with their IPv4 address and CIDR suffix.
function show_ipv4_cidr() {

  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | tail -n +2))
  
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints active network interfaces with their IPv6 address and CIDR suffix.
function show_ipv6_cidr() {
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV6_CIDR_ARRAY=($(ip -6 addr | grep inet6 | awk -F '[ \t]+|' '{print $3}' | grep -v ^::1 | grep -v ^fe80 | awk '{print toupper($0)}'))

  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}

# Prints all "basic" info and CIDR suffix.
function show_all_cidr() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet  | awk '{print $2}' | tail -n +2))
  declare -a IPV6_CIDR_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | tail -n +2 | awk '{print toupper($0)}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(cat < "/sys/class/net/${INTERFACES_ARRAY[i]}/address" | awk '{print toupper($0)}' 2>"${NULL}")
    printf "%-14s%-20s%-21s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
  exit
}

# Shows arp cache table.
function show_arp_cache() {
  
  local FILENAME
  
  FILENAME="ARP_CACHE"
  check_directory_or_touch_file "${FILENAME}"
  
  ip neigh | egrep -i 'permanent|noarp|stale|reachable|incomplete|delay|probe' | \
  grep -vi 'router' | \
  awk '{printf ("%-18s%-20s%s\n", $1, toupper($5), $6)}' >> "${TMP}/${FILENAME}"
  cat < "${TMP}/${FILENAME}" | sort -V
  mr_proper
  exit
}

# Prints bandwidth from different locations.
function show_bandwidth() {

  local HTTP_CODE
  local DOWNLOAD
  
  start_spinner "Checking ${GREEN}${CDN_TEST}${NORMAL}..." 
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${CDN_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Downloading from ${GREEN}${CDN_TEST}${NORMAL}..." 
    sleep 2
    DOWNLOAD=$(wget -O "${NULL}" --report-speed=bits "${CDN_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    stop_spinner $?
    printf "%-16s${GREEN}%s${NORMAL}\n" "Cachefly" "${DOWNLOAD}"
  else
    clear_line
    stop_spinner
    print_network_host_down "${CDN_TEST}"
	fi
  
  sleep 1.5
  
  start_spinner "Checking ${GREEN}${UK_TEST}${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${UK_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Downloading from ${GREEN}${UK_TEST}${NORMAL}..."
    sleep 2
    DOWNLOAD=$(wget -O "${NULL}" --report-speed=bits "${UK_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    stop_spinner $?
    printf "%-16s${GREEN}%s${NORMAL}\n" "UK" "${DOWNLOAD}"
  else
    clear_line
    stop_spinner $?
    print_network_host_down "${UK_TEST}"
  fi
  
  sleep 1.5
  
  start_spinner "Checking ${GREEN}${AUSTRALIA_TEST}${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${AUSTRALIA_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Downloading from ${GREEN}${AUSTRALIA_TEST}${NORMAL}..."
    sleep 2
    DOWNLOAD=$(wget -O "${NULL}" --report-speed=bits "${AUSTRALIA_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    stop_spinner $?
    printf "%-16s${GREEN}%s${NORMAL}\n" "Australia" "${DOWNLOAD}"
  else
    clear_line
    stop_spinner $?
	  print_network_host_down "${AUSTRALIA_TEST}"
	fi
  
  sleep 1.5
  
  start_spinner "Checking ${GREEN}${USA_TEST}${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${USA_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Downloading from ${GREEN}${USA_TEST}${NORMAL}..."
    sleep 2
    DOWNLOAD=$(wget -O "${NULL}" --report-speed=bits "${USA_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    stop_spinner $?
    printf "%-16s${GREEN}%s${NORMAL}\n" "USA" "${DOWNLOAD}"
  else
    clear_line
    stop_spinner $?
	  print_network_host_down "${USA_TEST}"
	fi
  
  sleep 1.5
  
  start_spinner "Checking ${GREEN}${SINGAPORE_TEST}${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${SINGAPORE_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Downloading from ${GREEN}${SINGAPORE_TEST}${NORMAL}..."
    sleep 2
    DOWNLOAD=$(wget -O "${NULL}" --report-speed=bits "${SINGAPORE_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    stop_spinner $?
    printf "%-16s${GREEN}%s${NORMAL}\n" "Singapore" "${DOWNLOAD}"
  else
    clear_line
    stop_spinner $?
	  print_network_host_down "${SINGAPORE_TEST}"
	fi
  
  sleep 1.5
  
  start_spinner "Checking ${GREEN}${NETHERLANDS_TEST}${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${NETHERLANDS_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Downloading from ${GREEN}${NETHERLANDS_TEST}${NORMAL}..."
    sleep 2
    DOWNLOAD=$(wget -O "${NULL}" --report-speed=bits "${NETHERLANDS_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    stop_spinner $?
    printf "%-16s${GREEN}%s${NORMAL}\n" "Netherlands" "${DOWNLOAD}"
  else
    clear_line
    stop_spinner $?
	  print_network_host_down "${NETHERLANDS_TEST}"
	fi
  
  sleep 1.5
  
  start_spinner "Checking ${GREEN}${FRANCE_TEST}${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${FRANCE_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Downloading from ${GREEN}${FRANCE_TEST}${NORMAL}..."
    sleep 2
    DOWNLOAD=$(wget -O "${NULL}" --report-speed=bits "${FRANCE_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    stop_spinner $?
    printf "%-16s${GREEN}%s${NORMAL}\n" "France" "${DOWNLOAD}"
  else
    clear_line
    stop_spinner $?
	  print_network_host_down "${FRANCE_TEST}"
	fi
  
  sleep 1.5
  
  start_spinner "Checking ${GREEN}${GREECE_TEST}${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${GREECE_TEST}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Downloading from ${GREEN}${GREECE_TEST}${NORMAL}..."
    sleep 2
    DOWNLOAD=$(wget -O "${NULL}" --report-speed=bits "${GREECE_TEST}" 2>&1 | grep -o "[0-9.]\+ [KMG]*b/s")
    clear_line
    stop_spinner $?
    printf "%-16s${GREEN}%s${NORMAL}\n" "Greece" "${DOWNLOAD}"
  else
    clear_line
    stop_spinner $?
	  print_network_host_down "${GREECE_TEST}"
	fi
  
  exit
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
  
  start_spinner "Checking ${GREEN}${FILTERED_URL}${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${FILTERED_URL}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  if [[ "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    start_spinner "Scanning..."
    sleep 2
    FILENAME="SCANNED_URL"
    check_directory_or_touch_file "${FILENAME}"
    wget --quiet "${SCAN}${FILTERED_URL}" -O "${TMP}/${FILENAME}"
    grep -i "safety\ reputation" "${TMP}/${FILENAME}" | \
    sed -e 's/<[^>]*>//g' | sed -e 's/[A-Za-z]*//g' | cut -f 1 -d "/" | \
    sed -e 's/^[ \t]*//' > "${TMP}/PARSED_URL_DATA"
    RESULT=$(cat ${TMP}/PARSED_URL_DATA)
    clear_line
    stop_spinner $?
    if [[ "${RESULT}" -eq 0 ]]; then
    # if results are zero
      echo -e "${FILTERED_URL} is ${GREEN}clean${NORMAL}"
    elif [[ "${RESULT}" -eq 1 ]]; then
    # if one result ==> false positive or low severity
      echo -e "${FILTERED_URL} is identified by $(cat ${TMP}/PARSED_URL_DATA) scanning engine (it may be false positive)"
      echo -e "${SCAN}${FILTERED_URL}"
    elif [[ "${RESULT}" -ge 2 ]] && [[ "${RESULT}" -le 4 ]]; then
    # if equal or greater than 2 and less or even that 4 ==> low severity
      echo -e "${FILTERED_URL} is identified by $(cat ${TMP}/PARSED_URL_DATA) scanning engines"
      echo -e "${SCAN}${FILTERED_URL}"
    elif [[ "${RESULT}" -ge 5 ]] && [[ "${RESULT}" -le 13 ]]; then
    # if equal or greater than 5 and less or even that 13 ==> medium severity
      echo -e "${ORANGE}${FILTERED_URL}${NORMAL} is identified by $(cat ${TMP}/PARSED_URL_DATA) scanning engines${NORMAL}"
      echo -e "${SCAN}${FILTERED_URL}"
    elif [[ "${RESULT}" -ge 14 ]]; then
    # if equal or greater than 14 ==> high severity
      echo -e "${RED}${FILTERED_URL}${NORMAL} is identified by $(cat ${TMP}/PARSED_URL_DATA) scanning engines${NORMAL}"
      echo -e "${SCAN}${FILTERED_URL}"
    else
      error_exit
    fi
    mr_proper
    exit
  else
    clear_line
    stop_spinner $?
    error_exit "${DIALOG_SERVER_IS_DOWN}"
  fi
}

# Prints the public IP address of a website or server. If $1 is empty prints user's public IP, if not, $1 should be example.com.
function show_ip_from() {
  
  local HTTP_CODE
  local FILENAME
  
  if [[ -z "$1" ]]; then
    start_spinner "Checking ${GREEN}${IPINFO}${NORMAL}..."
    sleep 2
    HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${IPINFO}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    if [[ "${HTTP_CODE}" -eq 200 ]]; then
      clear_line
      stop_spinner $?
      FILENAME="IP_FROM_THIS"
      check_directory_or_touch_file "${FILENAME}"
      start_spinner "Grabbing ${GREEN}IP${NORMAL}..."
      sleep 2
      wget "${IPINFO}/ip" -q -O "${TMP}/${FILENAME}"
      clear_line
      stop_spinner $?
      cat < "${TMP}/${FILENAME}"
      mr_proper
      exit
	  else
      clear_line
      stop_spinner $?
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  else
    start_spinner "Checking ${GREEN}$1${NORMAL}..."
    sleep 2
    HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "$1" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    if [[ "${HTTP_CODE}" -eq 200 ]]; then
      clear_line
      stop_spinner $?
      FILENAME="IPS_FROM"
      check_directory_or_touch_file "${FILENAME}"
      INPUT=$(echo "$1" | sed 's/^http\(\|s\):\/\///g' | cut -f 1 -d "/")
      start_spinner "Pinging ${GREEN}$1${NORMAL}..."
      sleep 2
      for i in {1..15}; do
        ping -4 -c 1 -i 0.2 -w 5 "${INPUT}" 2>"${NULL}" | awk -F '[()]' '/PING/{print $2}' >> "${TMP}/${FILENAME}" &
      done
      handle_jobs
      clear_line
      stop_spinner $?
      cat < "${TMP}/${FILENAME}" | sort -Vu
      mr_proper
      exit
    else
      clear_line
      stop_spinner $?
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
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
  
  ONLINE_INTERFACE=$(ip route get "${GOOGLE_DNS}" | awk -F "dev " 'NR == 1 { split($2, a, " "); print a[1] }')
  NETWORK_IP=$(ip route | grep "${ONLINE_INTERFACE}" | grep src | awk '{print $1}' | cut -f 1 -d "/")
  NETWORK_IP_CIDR=$(ip route | grep "${ONLINE_INTERFACE}" | grep src | awk '{print $1}')
  FILTERED_IP=$(echo "${NETWORK_IP}" | awk 'BEGIN{FS=OFS="."} NF--')

  case "$1" in
    "--normal")
      FILENAME="IPV4_OF_PING"
      check_directory_or_touch_file "${FILENAME}"
      start_spinner "Pinging ${GREEN}${NETWORK_IP_CIDR}${NORMAL}, please wait..."
      sleep 2
      for i in {1..254}; do
        ping "${FILTERED_IP}.${i}" -c 1 -w 5 >"${NULL}" &&
        echo "${FILTERED_IP}.${i}" >> "${TMP}/${FILENAME}" &
      done
      handle_jobs
      clear_line
      stop_spinner $?
      cat < "${TMP}/${FILENAME}" | sort -Vu
    ;;
    "--mac")
      start_spinner "Pinging ${GREEN}${NETWORK_IP_CIDR}${NORMAL}, please wait..."
      sleep 2
      for i in {1..254}; do
        ping "${FILTERED_IP}.${i}" -c 1 -w 5 >"${NULL}" &
      done
      handle_jobs
      clear_line
      stop_spinner $?
      ip neigh | egrep "${REGEX_MAC}" | grep -vi 'router' | awk '{printf ("%5s\t%s\n", $1, toupper($5))}' | sort -Vu
    ;;
  esac
  
  mr_proper
  exit
}

# Prints various location info of a domain. If $1 is empty prints user's location info, if not, $1 should be example.com.
function show_location_info() {
  
  local HTTP_CODE_IPINFO
  local INPUT
  local MAP_LOC
  local ZOOM
  local IP
  local HOSTNAME
  local CITY
  local REGION
  local COUNTRY
  local LOC
  local ORG  
  
  HTTP_CODE_IPINFO=$(wget --spider -t 1 --timeout=20 -S "${IPINFO}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  start_spinner "Checking ${GREEN}${IPINFO}${NORMAL}..."
  sleep 2
  if [[ ! "${HTTP_CODE_IPINFO}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    error_exit "${DIALOG_SERVER_IS_DOWN}"
  else
    clear_line
    stop_spinner $?
    if [[ ! -z "$1" ]]; then
      ZOOM="9"
      INPUT=$(echo "$1" | sed 's/^http\(\|s\):\/\///g' | cut -f 1 -d "/")
      start_spinner "Pinging ${GREEN}${INPUT}${NORMAL}..."
      sleep 2
      IP=$(ping -4 -c 1 -w 5 "${INPUT}" 2>"${NULL}" | awk -F'[()]' '/PING/{print $2}' &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}hostname${NORMAL}..."
      sleep 2
      HOSTNAME=$(wget -qO - ${IPINFO}/"${IP}"/hostname &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}city${NORMAL}..."
      sleep 2
      CITY=$(wget -qO - ${IPINFO}/"${IP}"/city &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}region${NORMAL}..."
      sleep 2
      REGION=$(wget -qO - ${IPINFO}/"${IP}"/region &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}country${NORMAL}..."
      sleep 2
      COUNTRY=$(wget -qO - ${IPINFO}/"${IP}"/country &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}location${NORMAL}..."
      sleep 2
      LOC=$(wget -qO - ${IPINFO}/"${IP}"/loc &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}organization${NORMAL}..."
      sleep 2
      ORG=$(wget -qO - ${IPINFO}/"${IP}"/org &)
      clear_line
      stop_spinner $?
      handle_jobs
      print_location_info "${IP}" "${HOSTNAME}" "${CITY}" "${REGION}" "${COUNTRY}" "${LOC}" "${ORG}"
      MAP_LOC="https://maps.googleapis.com/maps/api/staticmap?center=${LOC}&zoom=${ZOOM}&size=640x640&sensor=false"
      echo
      echo -e "${MAP_LOC}"
      exit
    else
      ZOOM="12"
      start_spinner "Grabbing ${GREEN}IP${NORMAL}..."
      sleep 2
      IP=$(wget -qO - ${IPINFO}/ip &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}hostname${NORMAL}..."
      sleep 2
      HOSTNAME=$(wget -qO - ${IPINFO}/"${IP}"/hostname &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}city${NORMAL}..."
      sleep 2
      CITY=$(wget -qO - ${IPINFO}/"${IP}"/city &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}region${NORMAL}..."
      sleep 2
      REGION=$(wget -qO - ${IPINFO}/"${IP}"/region &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}country${NORMAL}..."
      sleep 2
      COUNTRY=$(wget -qO - ${IPINFO}/"${IP}"/country &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}location${NORMAL}..."
      sleep 2
      LOC=$(wget -qO - ${IPINFO}/"${IP}"/loc &)
      clear_line
      stop_spinner $?
      start_spinner "Grabbing ${GREEN}organization${NORMAL}..."
      sleep 2
      ORG=$(wget -qO - ${IPINFO}/"${IP}"/org &)
      clear_line
      stop_spinner $?
      handle_jobs
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
  
  local PORT
  
  if [[ -z "$1" ]]; then
    print_port_protocol_list
    exit
  fi
  
  check_root_permissions
  check_if_parameter_is_not_numerical "$1"
  
  PORT="$1"
  
  clear
  while :; do
    clear
    echo -e "${DIALOG_PRESS_CTRL_C}"
    echo
    echo -e "      ${GREEN}┌─> ${RED}Count Port ${GREEN}──┐"
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
        start_spinner "Checking ${GREEN}$2${NORMAL}..."
        sleep 2
        HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${FILTERED_INPUT}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
        if [[ "${HTTP_CODE}" -eq 200 ]]; then
          clear_line
          stop_spinner $?
          start_spinner "Tracing path to ${GREEN}${FILTERED_INPUT}${NORMAL}..."
          sleep 2
          tracepath -n "${FILTERED_INPUT}" | awk '{print $2}' | egrep -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >> "${TMP}/${FILENAME}"
          clear_line
          stop_spinner $?
          cat < "${TMP}/${FILENAME}" | uniq
          mr_proper
          exit
        else
          clear_line
          stop_spinner $?
		      error_exit "${DIALOG_SERVER_IS_DOWN}"
        fi
      ;;
      "--ipv6")
        HAS_IPV6=$(cat < /proc/modules | grep -o ipv6)
        if [[ "${HAS_IPV6}" ]]; then
          start_spinner "Checking ${GREEN}$2${NORMAL}..."
          sleep 2
          HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${FILTERED_INPUT}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
          if [[ "${HTTP_CODE}" -eq 200 ]]; then
            clear_line
            stop_spinner $?
            start_spinner "Tracing path to ${FILTERED_INPUT}..."
            sleep 2
            tracepath6 -n "${FILTERED_INPUT}" | awk '{print $2}' | egrep -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >> "${TMP}/${FILENAME}"
            clear_line
            stop_spinner $?
            cat < "${TMP}/${FILENAME}" | uniq
            mr_proper
            exit
          else
            clear_line
            stop_spinner $?
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

# Prints in realtime download and upload speed.
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
  
  TKBPS="0.00"
  RKBPS="0.00"
  
  while :; do
    clear
    echo -e "${DIALOG_PRESS_CTRL_C}"
    echo
    printf "%-12s%s\n"     "Interface" "${ONLINE_INTERFACE}"
    printf "%-12s%-8s%s\n" "Download"  "${RKBPS}"            "KiB"
    printf "%-12s%-8s%s\n" "Upload"    "${TKBPS}"            "KiB"
    R1=$(cat /sys/class/net/"${ONLINE_INTERFACE}"/statistics/rx_bytes)
    T1=$(cat /sys/class/net/"${ONLINE_INTERFACE}"/statistics/tx_bytes)
    sleep .8
    R2=$(cat /sys/class/net/"${ONLINE_INTERFACE}"/statistics/rx_bytes)
    T2=$(cat /sys/class/net/"${ONLINE_INTERFACE}"/statistics/tx_bytes)
    TBPS=$((T2 - T1))
    RBPS=$((R2 - R1))
    TKBPS=$(printf "%0.2f" "$(bc -q <<< scale=2\;$TBPS/1024)")
    RKBPS=$(printf "%0.2f" "$(bc -q <<< scale=2\;$RBPS/1024)")
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
    if [[ ! $(hash ping6 2>"${NULL}") ]]; then
      case "$1" in
        "--ipv4")
          start_spinner "Playing ping pong with ${GREEN}Google${NORMAL}, please wait..."
          sleep 2
          PING_4=$(ping -4 -i 0.5 -c 10 ${GOOGLE_DNS} | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
          clear_line
          stop_spinner $?
          echo -e "Average RTT: ${GREEN}${PING_4} ms${NORMAL}"
          exit
        ;;
        "--ipv6")
          HAS_IPV6=$(cat < /proc/modules | grep -o ipv6)
          if [[ "${HAS_IPV6}" ]]; then
            start_spinner "Playing ping pong with ${GREEN}Google${NORMAL}, please wait..."
            sleep 2
            PING_6=$(ping -6 -i 0.5 -c 10 "${GOOGLE_DNS}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
            clear_line
            stop_spinner $?
            clear_line
            echo -e "Average RTT: ${GREEN}${PING_6} ms${NORMAL}"
            exit
          else
            error_exit "IPv6 unavailable. ${DIALOG_ABORTING}"
          fi
        ;;
      esac
    else
      case "$1" in
        "--ipv4")
          start_spinner "Playing ping pong with ${GREEN}Google${NORMAL}, please wait..."
          sleep 2
          PING_4=$(ping -i 0.5 -c 10 ${GOOGLE_DNS} | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
          clear_line
          stop_spinner $?
          echo -e "Average RTT: ${GREEN}${PING_4} ms${NORMAL}"
          exit
        ;;
        "--ipv6")
          HAS_IPV6=$(cat < /proc/modules | grep -o ipv6)
          if [[ "${HAS_IPV6}" ]]; then
            start_spinner "Playing ping pong with ${GREEN}Google${NORMAL}, please wait..."
            sleep 2
            PING_6=$(ping6 -i 0.5 -c 10 "${GOOGLE_DNS}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
            clear_line
            stop_spinner $?
            echo -e "Average RTT: ${GREEN}${PING_6} ms${NORMAL}"
            exit
          else
            error_exit "IPv6 unavailable. ${DIALOG_ABORTING}"
          fi
        ;;
      esac
    fi
  else
    FILTERED_URL=$(echo "$2" | sed 's/^http\(\|s\):\/\///g' | sed 's/www.//' | cut -f 1 -d "/")
    start_spinner "Checking ${GREEN}${FILTERED_URL}${NORMAL}..."
    sleep 2
    HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "${FILTERED_URL}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    if [[ "${HTTP_CODE}" -eq 200 ]]; then
      clear_line
      stop_spinner $?
      if [[ ! $(hash ping6 2>"${NULL}") ]]; then
        case "$1" in
          "--ipv4")
            start_spinner "Playing ping pong with ${GREEN}${FILTERED_URL}${NORMAL}, please wait..."
            sleep 2
            PING_4=$(ping -4 -i 0.5 -c 10 "${FILTERED_URL}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
            clear_line
            stop_spinner $?
            echo -e "Average response time: ${GREEN}${PING_4} ms${NORMAL}"
            exit
          ;;
          "--ipv6")
            HAS_IPV6=$(cat < /proc/modules | grep -o ipv6)
            if [[ "${HAS_IPV6}" ]]; then
              start_spinner "Playing ping pong with ${GREEN}${FILTERED_URL}${NORMAL}, please wait..."
              sleep 2
              PING_6=$(ping -6 -i 0.5 -c 10 "${FILTERED_URL}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
              clear_line
              stop_spinner $?
              echo -e "Average response time: ${GREEN}${PING_6} ms${NORMAL}"
              exit
            else
              error_exit "IPv6 unavailable. ${DIALOG_ABORTING}"
            fi
          ;;
        esac
      fi
    else
      case "$1" in
        "--ipv4")
          start_spinner "Playing ping pong with ${GREEN}${FILTERED_URL}${NORMAL}, please wait..."
          sleep 2
          PING_4=$(ping -4 -i 0.5 -c 10 "${FILTERED_URL}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
          clear_line
          stop_spinner $?
          echo -e "Average response time: ${GREEN}${PING_4} ms${NORMAL}"
          exit
        ;;
        "--ipv6")
          HAS_IPV6=$(cat < /proc/modules | grep -o ipv6)
          if [[ "${HAS_IPV6}" ]]; then
            start_spinner "Playing ping pong with ${GREEN}${FILTERED_URL}${NORMAL}, please wait..."
            sleep 2
            PING_6=$(ping -6 -i 0.5 -c 10 "${FILTERED_URL}" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
            clear_line
            stop_spinner $?
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

# Extracts valid IPv4, IPv6 and MAC addresses from a URL.
function show_ips_from_url() {
  
  if [[ -z "$1" ]]; then 
    error_exit "No URL was specified. ${DIALOG_ABORTING}"
  fi
  
  local HTTP_CODE
  local FILENAME_URL
  local FILENAME_IPV4
  local FILENAME_IPV6
  local FILENAME_MAC
  
  start_spinner "Checking ${GREEN}$1${NORMAL}..."
  sleep 2
  HTTP_CODE=$(wget --spider -t 1 --timeout=20 -S "$1" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  
  if [[ ! "${HTTP_CODE}" -eq 200 ]]; then
    clear_line
    stop_spinner $?
    echo -e "Destination is unreachable. Input was invalid or server is down or has connection issues. ${DIALOG_ABORTING}"
    error_exit
  fi
  
  clear_line
  stop_spinner $?

  FILENAME_URL="DOWNLOADED_SITE_TO_EXTRACT_IPS"
  FILENAME_IPV4="IPV4_OF_FILE"
  FILENAME_IPV6="IPV6_OF_FILE"
  FILENAME_MAC="MAC_OF_FILE"
  
  check_directory_or_touch_file "${FILENAME_URL}"
  check_directory_or_touch_file "${FILENAME_IPV4}"
  check_directory_or_touch_file "${FILENAME_IPV6}"
  check_directory_or_touch_file "${FILENAME_MAC}"
  
  start_spinner "Downloading ${GREEN}${1}${NORMAL}..."
  sleep 2
  wget -q "$1" -O "${TMP}/${FILENAME_URL}"
  clear_line
  stop_spinner $?

  grep -E -o "${REGEX_IPV4}" "${TMP}/${FILENAME_URL}" | sort -Vu >> "${TMP}/${FILENAME_IPV4}" &
  grep -E -o "${REGEX_IPV6}" "${TMP}/${FILENAME_URL}" | sort -Vu >> "${TMP}/${FILENAME_IPV6}" &
  grep -E -o "${REGEX_MAC}"  "${TMP}/${FILENAME_URL}" | sort -Vu >> "${TMP}/${FILENAME_MAC}"  &
  
  if [[ ! -s "${TMP}/${FILENAME_IPV4}" ]] && [[ ! -s "${TMP}/${FILENAME_IPV6}" ]] && [[ ! -s "${TMP}/${FILENAME_MAC}" ]]; then
  # if no valid addresses found, exit.
    error_exit "No valid IPv4, IPv6 or MAC addresses found. ${DIALOG_ABORTING}"
  elif [[ -s "${TMP}/${FILENAME_MAC}" ]] && [[ -s "${TMP}/${FILENAME_IPV4}" ]] && [[ -s "${TMP}/${FILENAME_IPV6}" ]]; then
  # if there are valid IPv4, IPv6 and MAC addresses...
    paste "${TMP}/${FILENAME_IPV4}" "${TMP}/${FILENAME_IPV6}" "${TMP}/${FILENAME_MAC}" | awk -F '\t' '{printf("%-16s%-40s%s\n", $1, $2, $3)}'
  elif [[ ! -s "${TMP}/${FILENAME_MAC}" ]] && [[ -s "${TMP}/${FILENAME_IPV4}" ]] && [[ -s "${TMP}/${FILENAME_IPV6}" ]]; then
  # if there are only                                                  ^^^^addresses                         ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV4}" "${TMP}/${FILENAME_IPV6}" | awk -F '\t' '{printf("%-16s%s\n", $1, $2)}' 
  elif [[ ! -s "${TMP}/${FILENAME_IPV4}" ]] && [[ -s "${TMP}/${FILENAME_MAC}" ]] && [[ -s "${TMP}/${FILENAME_IPV6}" ]]; then 
  # if there are only                                                   ^^^addresses                         ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV6}" "${TMP}/${FILENAME_MAC}" | awk -F '\t' '{printf("%-40s%s\n", $1, $2)}'
  elif [[ ! -s "${TMP}/${FILENAME_IPV6}" ]] && [[ -s "${TMP}/${FILENAME_MAC}" ]] && [[ -s "${TMP}/${FILENAME_IPV4}" ]]; then 
  # if there are only                                                   ^^^addresses                         ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV4}" "${TMP}/${FILENAME_MAC}" | awk -F '\t' '{printf("%-16s%s\n", $1, $2)}'
  elif [[ ! -s "${TMP}/${FILENAME_MAC}" ]] && [[ ! -s "${TMP}/${FILENAME_IPV6}" ]] && [[ -s "${TMP}/${FILENAME_IPV4}" ]]; then
  # if there are only                                                                                          ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV4}" | awk -F '\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${TMP}/${FILENAME_MAC}" ]] && [[ ! -s "${TMP}/${FILENAME_IPV4}" ]] && [[ -s "${TMP}/${FILENAME_IPV6}" ]]; then 
  # if there are only                                                                                          ^^^^addresses...
    paste "${TMP}/${FILENAME_IPV6}" | awk -F '\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${TMP}/${FILENAME_IPV4}" ]] && [[ ! -s "${TMP}/${FILENAME_IPV6}" ]] && [[ -s "${TMP}/${FILENAME_MAC}" ]]; then
  # if there are only                                                                                           ^^^addresses...
    paste "${TMP}/${FILENAME_MAC}" | awk -F '\t' '{printf("%s\n", $1)}'
  fi
  
  mr_proper
  exit
}

########################## EOF MAIN FUNCTIONS ##########################

# Spinner main function.
function spinner() {
  
  # $1 start/stop
  #
  # on start: $2 display message
  # on stop : $2 process exit status
  #           $3 spinner function pid (supplied from stop_spinner)
  
  local STEP
  local SPINNER_PARTS
  local DELAY

  case $1 in
    start)
      # calculate the column where spinner and status msg will be displayed
      let COLUMN=$(tput cols)-${#2}-8
      # display message and position the cursor in $COLUMN column
      echo -ne "${2}"
      printf "%${COLUMN}s"

      # start spinner
      STEP=1
      SPINNER_PARTS='\|/-'
      DELAY=${SPINNER_DELAY:-0.15}

      while :; do
        printf "\b%s" "${SPINNER_PARTS:STEP++%${#SPINNER_PARTS}:1}"
        sleep "${DELAY}"
      done
    ;;
    stop)
      kill "$3" > /dev/null 2>&1
    ;;
    *)
      echo "Invalid argument!"
      exit 1
    ;;
  esac
}

# Start spinner with $1 as message.
function start_spinner {
  
  # $1 : msg to display
  spinner "start" "${1}" &
  # set global spinner pid
  SPINNER_ID=$!
  disown
}

# Stops spinner.
function stop_spinner {
  
  # $1 : command exit status
  spinner "stop" "$1" "${SPINNER_ID}"
  unset SPINNER_ID
}

# Prints show_location_info() data.
function print_location_info() {
  
  echo
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

  declare -a PORTS_ARRAY=("20-21" "22" "23" "25" "53" "67-68" "69" "80" "110" \
               "123" "137-139" "143" "161-162" "179" "389" "443" "636" \
               "989-990")
  declare -a PORTS_TCP_UDP_ARRAY=("TCP" "TCP" "TCP" "TCP" "TCP/UDP" "UDP" "UDP" \
                       "TCP" "TCP" "UDP" "TCP/UDP" "TCP" "TCP/UDP" "TCP"\
                       "TCP/UDP" "TCP" "TCP/UDP" "TCP")
  declare -a PORTS_PROTOCOL_ARRAY=("FTP" "SSH" "Telnet" "SMTP" "DNS" "DHCP" "TFTP" \
                        "HTTP" "POPv3" "NTP" "NetBIOS" "IMAP" "SNMP" \
                        "BGP" "LDAP" "HTTPS" "LDAPS" "FTP over TLS/SSL")

  for i in "${!PORTS_ARRAY[@]}"; do
    printf "%-17s%-8s%s\n" "${PORTS_PROTOCOL_ARRAY[i]}" "${PORTS_TCP_UDP_ARRAY[i]}" "${PORTS_ARRAY[i]}"
  done
  exit
}

# Informs when a network host is down. Requires $1 as the host.
function print_network_host_down() {
  
  echo -e "${DIALOG_SERVER_IS_DOWN}"
}

# Clears previous line.
function clear_line() {
  
  printf "\r\033[K"
}

# Checks network connection (local or internet).
function check_connectivity() {
  
  case "$1" in
    "--local") ip route | grep "^default" >"${NULL}" || error_exit "${DIALOG_NO_LOCAL_CONNECTION}" ;;
    "--internet") ping -q -c 1 -W 1 "${GOOGLE_DNS}" >"${NULL}" || error_exit "${DIALOG_NO_INTERNET}" ;;
  esac
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

# Checks if /tmp/ship exists, if not creates the dir and touches file/s given by functions.
function check_directory_or_touch_file() {
  
  if [[ ! -d "${TMP}" ]]; then
    mkdir "${TMP}"
    if [[ ! -z "$1" ]]; then touch "${TMP}/$1" 2>"${NULL}"; fi
  fi

}

# Checks for root privileges.
function check_root_permissions() {
  
  if [[ "$(id -u)" -ne "0" ]]; then
    error_exit "${GREEN}ship${NORMAL} requires ${RED}root${NORMAL} privileges for this action."
  fi
}

# Checks Bash version. Minimum is version 3.2.
function check_bash_version() {
  
  if [[ "${BASH_VERSINFO[0]}" -lt 3 ]] || [[ "${BASH_VERSINFO[1]}" -lt 2 ]]; then
    error_exit "Sorry, you need at least bash-3.2 to set sail."
  fi
}

# Deletes every file that is created by this script. Usually in /tmp.
function mr_proper() {
  
  rm -rf "${TMP}"
}

# Traps INT and SIGTSTP.
function trap_handler() {
  
  local YESNO
  
  echo
  YESNO=""
	while [[ ! "${YESNO}" =~ ^[YyNn]$ ]]; do
		echo -ne "Exit? [y/n] "
    read -r YESNO 2>"${NULL}"
	done

	if [[ "${YESNO}" = "Y" ]]; then
		YESNO="y"
	elif [[ "${YESNO}" = "N" ]]; then
		YESNO="n"
	fi
  
	if [[ "${YESNO}" = "y" ]]; then
    handle_jobs
    clear_line
    mr_proper
    exit
  fi
}

# Used with zero parameters: exit 1.
# Used with one parameter  : echoes parameter, usually error dialogs.
# Used with two parameters : invalid option, then echoes first parameter, usually error dialogs.
function error_exit() {
  
  if [[ -z "$1" ]]; then
    mr_proper
    exit 1
  elif [[ -z "$2" ]]; then
    echo -e  "$1"
    mr_proper
    exit 1
  else
    echo -e  "${GREEN}ship${NORMAL}: invalid option -- '$2'" 
    echo -e  "$1"
    mr_proper
    exit 1
  fi
}

# Background tasks' handeler.
function handle_jobs() {
  
  local JOB
  
  for JOB in $(jobs -p); do wait "${JOB}"; done
}

# Starts ship.
function sail() {
  
  if [[ -z "$1" ]]; then error_exit "${DIALOG_ERROR}"; fi
  
  trap trap_handler INT 2>"${NULL}"
  trap trap_handler SIGTSTP 2>"${NULL}"
  check_bash_version
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
            "-d"|"--driver") check_connectivity "--local"; show_driver; break ;;
            "-E"|"--external") check_connectivity "--internet"; show_ip_from "$2"; shift 2; break ;;
            "-f"|"--find") show_ips_from_file "$2"; shift 2; break ;;
            "-g"|"--gateway") check_connectivity "--local"; show_gateway; break ;;
            "-H"|"--hosts") check_connectivity "--internet"; show_live_hosts --normal; break ;;
           "-HM"|"--hosts-mac") check_connectivity "--internet"; show_live_hosts --mac; break ;;
            "-h"|"--help") show_usage; break ;;
            "-i"|"--interfaces") check_connectivity "--local"; show_interfaces; break ;;
            "-L"|"--location") check_connectivity "--internet"; show_location_info "$2"; shift 2; break ;;
            "-P"|"--port") check_connectivity "--internet"; show_port_connections "$2"; shift 2; break ;;
            "-R"|"--route") check_connectivity "--internet"; show_next_hops --ipv4 "$2"; shift 2; break ;;
           "-R6"|"--route-ipv6") check_connectivity "--internet"; show_next_hops --ipv6 "$2"; shift 2; break ;;
            "-m"|"--mac") check_connectivity "--local"; show_mac; break ;;
            "-S"|"--speed") check_connectivity "--internet"; show_speed; break ;;
            "-T"|"--time") check_connectivity "--internet"; show_avg_ping --ipv4 "$2"; shift 2; break ;;
           "-T6"|"--time-ipv6") check_connectivity "--internet"; show_avg_ping --ipv6 "$2"; shift 2; break ;;
            "-U"|"--url") check_connectivity "--internet"; show_ips_from_url "$2"; shift 2; break ;;
            "-v"|"--version") show_version; break ;;
      "--cidr-4"|"--cidr-ipv4") check_connectivity "--local"; show_ipv4_cidr; break ;;
      "--cidr-6"|"--cidr-ipv6") check_connectivity "--local"; show_ipv6_cidr; break ;;
      "--cidr-a"|"--cidr-all") check_connectivity "--local"; show_all_cidr; break ;;
      *) error_exit "${DIALOG_ERROR}" "$1"; break ;;
    esac
  done
}

sail "$1" "$2"
