#!/bin/bash
#### Description......: Show IPv4, IPv6 and MAC addresses, and many more.
#### Written by.......: Sotirios Roussis (aka. xtonousou) - xtonousou@gmail.com on 10-2016
#### Known limitations: ipinfo.io offers free 1,000 daily requests. (ship -f)

### INFO
AUTHOR="Sotirios Roussis"
AUTHOR_NICKNAME="xtonousou"
GMAIL="${AUTHOR_NICKNAME}@gmail.com"
GITHUB="https://github.com/${AUTHOR_NICKNAME}"
VERSION="2.1"

### Colors
GREEN="\033[1;32m"
_RED_="\033[1;31m"
CYAN="\033[1;36m"
ORANGE="\033[1;33m"
NORMAL="\e[1;0m"

### Locations
TEMP="/tmp"
GOOGLE_DNS="8.8.8.8"
IPINFO="ipinfo.io"

### Dialogs
DIALOG_PRESS_CTRL_C="Press [CTRL+C] to stop"
DIALOG_ERROR="Try ${GREEN}ship --help${NORMAL} for more information."
DIALOG_ABORTING="${_RED_}Aborting${NORMAL}."
DIALOG_NO_INTERNET="Internet connection unavailable. ${DIALOG_ABORTING}"
DIALOG_NO_LOCAL_CONNECTION="Local connection unavailable. ${DIALOG_ABORTING}"
DIALOG_SERVER_IS_DOWN="Destination is unreachable. Server may be down or has connection issues. ${DIALOG_ABORTING}"
DIALOG_NOT_A_NUMBER="Option should be integer. ${DIALOG_ABORTING}"
DIALOG_NO_ARGUMENTS="No arguments. ${DIALOG_ABORTING}"
DIALOG_NO_TRACE_COMMAND="You need at least one of the following tools to run this command: ${ORANGE}tracepath${NORMAL}, ${ORANGE}traceroute${NORMAL}, ${ORANGE}mtr${NORMAL}. ${DIALOG_ABORTING}"

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

### Other Values
SHORT_TIMEOUT="2"
TIMEOUT="5"
LONG_TIMEOUT="15"
FILENAME_PREFIX="${TEMP}/ship-"

########################################################################
#                                                                      #
#  Main script's functions in alphabetical order based on show_usage() #
#                                                                      #
########################################################################

# Prints active network interfaces with their IPv4 address.
function show_ipv4() {
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV4_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done
}

# Prints active network interfaces with their IPv6 address.
function show_ipv6() {
  
  check_ipv6
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2 | awk '{print toupper($0)}'))  

  for i in "${!INTERFACES_ARRAY[@]}"; do
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
}

# Prints all "basic" info.
function show_all() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV4_ARRAY=($(ip addr show | grep -w inet  | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2))
  declare -a IPV6_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | cut -d "/" -f 1 | tail -n +2 | awk '{print toupper($0)}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(cat < "/sys/class/net/${INTERFACES_ARRAY[i]}/address" | awk '{print toupper($0)}' 2> /dev/null)
    printf "%-14s%-20s%-18s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
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

# Prints the public IP address of a website or server. If $1 is empty prints user's public IP, if not, $1 should be example.com.
function show_ip_from() {
  
  local HTTP_CODE
  local FILENAME
  
  if [[ -z "$1" ]]; then
    print_check "${IPINFO}"
    HTTP_CODE=$(wget --spider -t 1 --timeout="${TIMEOUT}" -S "${IPINFO}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    
    if [[ "${HTTP_CODE}" -eq 200 ]]; then
      clear_line
      FILENAME="external_ip"
      check_and_touch "${FILENAME}"
      
      echo -ne "Grabbing ${GREEN}IP${NORMAL} ..."
      wget "${IPINFO}/ip" -q -O "${FILENAME_PREFIX}${FILENAME}"
      
      clear_line
      cat < "${FILENAME_PREFIX}${FILENAME}"
      
      mr_proper
	  else
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  else
    print_check "$1"
    HTTP_CODE=$(wget --spider -t 1 --timeout="${TIMEOUT}" -S "$1" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
    
    if [[ "${HTTP_CODE}" -eq 200 ]]; then
      clear_line
      FILENAME="ips_from_$1"
      check_and_touch "${FILENAME}"
      INPUT=$(echo "$1" | sed 's/^http\(\|s\):\/\///g' | cut -f 1 -d "/")
      
      echo -ne "Pinging ${GREEN}$1${NORMAL} ..."
      for i in {1..15}; do
        ping -4 -c 1 -i 0.2 -w "${LONG_TIMEOUT}" "${INPUT}" 2> /dev/null | awk -F '[()]' '/PING/{print $2}' >> "${FILENAME_PREFIX}${FILENAME}" &
      done
      handle_jobs
      
      clear_line
      cat < "${FILENAME_PREFIX}${FILENAME}" | sort -Vu
      
      mr_proper
    else
		  error_exit "${DIALOG_SERVER_IS_DOWN}"
	  fi
  fi
}

# Prints all IPv4 or IPv6 addresses extracted from a file.
function show_ips_from_file() {
    
  if [[ -z "$1" ]]; then
    error_exit "No file was specified. ${DIALOG_ABORTING}"
  fi
  
  local FILENAME_IPV4
  local FILENAME_IPV6
  local FILENAME_MAC

  FILENAME_IPV4="ipv4s_from_$1"
  FILENAME_IPV6="ipv6s_from_$1"
  FILENAME_MAC="macs_from_$1"
  
  check_and_touch "${FILENAME_IPV4}"
  check_and_touch "${FILENAME_IPV6}"
  check_and_touch "${FILENAME_MAC}"
  
  if [[ ! -f "$1" ]]; then
    error_exit "No such file. ${DIALOG_ABORTING}"
  fi
  
  # maybe add a function to check if it is a huge file
  # if it is huge (heh xD), use & on each grep
  
  grep -E -o "${REGEX_IPV4}" "$1" | sort -Vu >> "${FILENAME_PREFIX}${FILENAME_IPV4}"
  grep -E -o "${REGEX_IPV6}" "$1" | sort -Vu >> "${FILENAME_PREFIX}${FILENAME_IPV6}"
  grep -E -o "${REGEX_MAC}"  "$1" | sort -Vu >> "${FILENAME_PREFIX}${FILENAME_MAC}" 
  
  handle_jobs
  
  if [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]]; then
  # if no valid addresses found, exit.
    error_exit "No valid IPv4, IPv6 or MAC addresses found. ${DIALOG_ABORTING}"
  elif [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then
  # if there are valid IPv4, IPv6 and MAC addresses...  
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_IPV6}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk -F '\t' '{printf("%-16s%-40s%s\n", $1, $2, $3)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then
  # if there are only                                                  ^^^^addresses                         ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_IPV6}" | awk -F '\t' '{printf("%-16s%s\n", $1, $2)}' 
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then 
  # if there are only                                                   ^^^addresses                         ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV6}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk -F '\t' '{printf("%-40s%s\n", $1, $2)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]]; then 
  # if there are only                                                   ^^^addresses                         ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk -F '\t' '{printf("%-16s%s\n", $1, $2)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]]; then 
  # if there are only                                                                                          ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" | awk -F '\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then 
  # if there are only                                                                                          ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV6}" | awk -F '\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]]; then 
  # if there are only                                                                                           ^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_MAC}" | awk -F '\t' '{printf("%s\n", $1)}'
  fi
  
  mr_proper
}

# Prints active network interfaces and their gateway.
function show_gateway() {
  
  local GATEWAY
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(ip route | grep "${INTERFACES_ARRAY[i]}" | grep ^default | awk '{print $3}')
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done
}

# Scans live hosts on network and prints their IPv4 address with or without MAC address. ICMP and ARP.
function show_live_hosts() {
  
  check_root_permissions
  
  local ONLINE_INTERFACE
  local NETWORK_IP
  local NETWORK_IP_CIDR
  local FILTERED_IP
  local FILENAME
  
  ONLINE_INTERFACE=$(ip route get "${GOOGLE_DNS}" | awk -F "dev " 'NR == 1 { split($2, a, " "); print a[1] }')
  NETWORK_IP=$(ip route | grep "${ONLINE_INTERFACE}" | grep src | awk '{print $1}' | cut -f 1 -d "/")
  NETWORK_IP_CIDR=$(ip route | grep "${ONLINE_INTERFACE}" | grep src | awk '{print $1}')
  FILTERED_IP=$(echo "${NETWORK_IP}" | awk 'BEGIN{FS=OFS="."} NF--')

  # maybe in next updates, I will be more gentle ...
  # user might not want to flush arp cache for various reasons
  # maybe I could add another option or find a better solution
  ip -s -s neigh flush all > /dev/null
  
  echo -ne "Pinging ${GREEN}${NETWORK_IP_CIDR}${NORMAL}, please wait ..."
  for i in {1..254}; do
    ping "${FILTERED_IP}.${i}" -c 1 -w "${LONG_TIMEOUT}" > /dev/null &
  done
  handle_jobs
  
  clear_line
  
  case "$1" in
    "--normal")
      ip neigh | egrep "${REGEX_IPV4}" | egrep -i "reachable|stale|delay|probe" | awk '{print $1}' | sort -Vu
    ;;
    "--mac")      
      ip neigh | egrep "${REGEX_MAC}" | egrep -i "reachable|stale|delay|probe" | awk '{printf ("%5s\t%s\n", $1, toupper($5))}' | sort -Vu
    ;;
  esac
  
  mr_proper
}

# Prints active network interfaces.
function show_interfaces() {
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))

  printf "%s\n" "${INTERFACES_ARRAY[@]}"
}

# Prints connections and the count of them per IP.
function show_port_connections() {
  
  local PORT
  
  if [[ -z "$1" ]]; then
    print_port_protocol_list
    exit 0
  fi
  
  check_root_permissions
  check_if_parameter_is_not_numerical "$1"
  
  PORT="$1"
  
  clear
  while :; do
    clear
    echo -e "${DIALOG_PRESS_CTRL_C}"
    echo
    echo -e "      ${GREEN}┌─> ${_RED_}Count Port ${GREEN}──┐"
    echo -e "      │ ┌───────> ${_RED_}IPv4 ${GREEN}└─> ${_RED_}${PORT}"
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
  local PROTOCOL
  local __TRACEPATH__
  local __TRACEROUTE__
  local __MTR__
  
  if hash tracepath 2> /dev/null; then __TRACEPATH__=1; else __TRACEPATH__=0; fi
  if hash traceroute 2> /dev/null; then __TRACEROUTE__=1; else __TRACEROUTE__=0; fi
  if hash mtr 2> /dev/null; then __MTR__=1; else __MTR__=0; fi
  
  if [[ -z "$2" ]]; then
    error_exit "${DIALOG_NO_ARGUMENTS}"
  else
    FILTERED_INPUT=$(echo "$2" | sed 's/^http\(\|s\):\/\///g' | cut -f 1 -d "/")
    FILENAME="next_hops_for_${FILTERED_INPUT}"
    check_and_touch "${FILENAME}"

    case "$1" in
      "--ipv4") PROTOCOL=4; ;;
      "--ipv6") check_ipv6; PROTOCOL=6; ;;
    esac

    print_check "$2"
    HTTP_CODE=$(wget --spider -t 1 --timeout="${TIMEOUT}" -S "${FILTERED_INPUT}" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
        
    if [[ "${HTTP_CODE}" -eq 200 ]]; then
      clear_line
      echo -ne "Tracing path to ${GREEN}${FILTERED_INPUT}${NORMAL} ..."

      # traceroute is deprecated, nevertheless it is preferred over tracepath
      # treroute is preferred over all
      case "${__TRACEPATH__}:${__TRACEROUTE__}:${__MTR__}" in
        # If none of the tools (tracepath, traceroute, mtr) is installed
        0:0:0)
          echo -e "${DIALOG_NO_TRACE_COMMAND}"
        ;;
        # If it is installed 'mtr' only
        0:0:1)
          mtr -"${PROTOCOL}" -c 2 -n --report "${FILTERED_INPUT}" | egrep -o "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        # If it is installed 'traceroute' only
        0:1:0)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" | awk '{print $2}' | egrep -o "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        # If it is installed 'traceroute' and 'mtr' only
        0:1:1)
          mtr -"${PROTOCOL}" -c 2 -n --report "${FILTERED_INPUT}" | egrep -o "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        # If it is installed 'tracepath' only
        1:0:0)
          # tracepath6 workaround: Many linux distributions do not have tracepath6 (it is included in manpages tho :/)
          if hash tracepath6 2> /dev/null; then PROTOCOL=6; else PROTOCOL=""; fi
          
          timeout "${SHORT_TIMEOUT}" tracepath"${PROTOCOL}" -n "${FILTERED_INPUT}" | awk '{print $2}' | egrep -o "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        # If it is installed 'tracepath' and 'mtr' only
        1:0:1)
          mtr -"${PROTOCOL}" -c 2 -n --report "${FILTERED_INPUT}" | egrep -o "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        # If it is installed 'tracepath' and 'traceroute' only
        1:1:0)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" | awk '{print $2}' | egrep -o "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        # If it is installed 'tracepath', 'traceroute' and 'mtr'
        1:1:1)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" | awk '{print $2}' | egrep -o "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
      esac
          
      clear_line
      cat < "${FILENAME_PREFIX}${FILENAME}" | uniq

      mr_proper
    else
      error_exit "${DIALOG_SERVER_IS_DOWN}"
    fi
  fi  
}

# Prints active network interfaces with their MAC address.
function show_mac() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(cat < "/sys/class/net/${INTERFACES_ARRAY[i]}/address" | awk '{print toupper($0)}' 2> /dev/null)
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
  done
}

# Shows neighbor table.
function show_neighbor_cache() {
  
  local FILENAME
  
  FILENAME="neighbors"
  check_and_touch "${FILENAME}"
  
  ip neigh | egrep -i 'permanent|noarp|stale|reachable|incomplete|delay|probe' | \
  grep -vi 'router' | \
  awk '{printf ("%-16s%-20s%s\n", $1, toupper($5), $6)}' >> "${FILENAME_PREFIX}${FILENAME}"
  cat < "${FILENAME_PREFIX}${FILENAME}" | sort -V
  
  mr_proper
}

# Extracts valid IPv4, IPv6 and MAC addresses from a URL.
function show_ips_from_url() {
  
  if [[ -z "$1" ]]; then 
    error_exit "No URL was specified. ${DIALOG_ABORTING}"
  fi
  
  local HTTP_CODE
  local FILENAME_HTML
  local FILENAME_IPV4
  local FILENAME_IPV6
  local FILENAME_MAC
  
  print_check "$1"
  HTTP_CODE=$(wget --spider -t 1 --timeout="${TIMEOUT}" -S "$1" 2>&1 | grep "HTTP/" | awk '{print $2}' | tail -n1)
  
  clear_line
  
  if [[ ! "${HTTP_CODE}" -eq 200 ]]; then
    error_exit "Destination is unreachable. Input was invalid or server is down or has connection issues. ${DIALOG_ABORTING}"
  fi

  FILENAME_HTML="doc_to_be_extracted"
  FILENAME_IPV4="ipv4s_of_doc"
  FILENAME_IPV6="ipv6s_of_doc"
  FILENAME_MAC="macs_of_doc"
  
  check_and_touch "${FILENAME_HTML}"
  check_and_touch "${FILENAME_IPV4}"
  check_and_touch "${FILENAME_IPV6}"
  check_and_touch "${FILENAME_MAC}"
  
  echo -ne "Downloading ${GREEN}$1${NORMAL} ..."
  wget -q "$1" -O "${FILENAME_PREFIX}${FILENAME_HTML}"
  clear_line

  grep -E -o "${REGEX_IPV4}" "${FILENAME_PREFIX}${FILENAME_HTML}" | sort -Vu >> "${FILENAME_PREFIX}${FILENAME_IPV4}"
  grep -E -o "${REGEX_IPV6}" "${FILENAME_PREFIX}${FILENAME_HTML}" | sort -Vu >> "${FILENAME_PREFIX}${FILENAME_IPV6}"
  grep -E -o "${REGEX_MAC}"  "${FILENAME_PREFIX}${FILENAME_HTML}" | sort -Vu >> "${FILENAME_PREFIX}${FILENAME_MAC}"
  
  if [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]]; then
  # if no valid addresses found, exit.
    error_exit "No valid IPv4, IPv6 or MAC addresses found. ${DIALOG_ABORTING}"
  elif [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then
  # if there are valid IPv4, IPv6 and MAC addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_IPV6}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk -F '\t' '{printf("%-16s%-40s%s\n", $1, $2, toupper($3))}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then
  # if there are only                                                                        ^^^^addresses                                    ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_IPV6}" | awk -F '\t' '{printf("%-16s%s\n", $1, $2)}' 
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then 
  # if there are only                                                                         ^^^addresses                                    ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV6}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk -F '\t' '{printf("%-40s%s\n", $1, toupper($2))}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]]; then 
  # if there are only                                                                         ^^^addresses                                    ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk -F '\t' '{printf("%-16s%s\n", $1, toupper($2))}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]]; then
  # if there are only                                                                                                                           ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" | awk -F '\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then 
  # if there are only                                                                                                                           ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV6}" | awk -F '\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]]; then
  # if there are only                                                                                                                            ^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_MAC}" | awk -F '\t' '{printf("%s\n", toupper($1))}'
  fi
  
  mr_proper
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

  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet | awk '{print $2}' | tail -n +2))
  
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done
}

# Prints active network interfaces with their IPv6 address and CIDR suffix.
function show_ipv6_cidr() {
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV6_CIDR_ARRAY=($(ip -6 addr | grep inet6 | awk -F '[ \t]+|' '{print $3}' | grep -v ^::1 | grep -v ^fe80 | awk '{print toupper($0)}'))

  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    printf "%-14s%s\n" "${INTERFACES_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
}

# Prints all info and CIDR suffix.
function show_all_cidr() {
  
  local MAC_OF
  
  declare -a INTERFACES_ARRAY=($(ip route | grep "default" | awk '{print $5}'))
  declare -a IPV4_CIDR_ARRAY=($(ip addr show | grep -w inet  | awk '{print $2}' | tail -n +2))
  declare -a IPV6_CIDR_ARRAY=($(ip addr show | grep -w inet6 | awk '{print $2}' | tail -n +2 | awk '{print toupper($0)}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(cat < "/sys/class/net/${INTERFACES_ARRAY[i]}/address" | awk '{print toupper($0)}' 2> /dev/null)
    printf "%-14s%-20s%-21s%s\n" "${INTERFACES_ARRAY[i]}" "${MAC_OF}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
}

# Prints help message.
function show_usage() {
  
  echo    " usage: ship [OPTION] <ARGUMENT>"
  echo -e "  ${GREEN}ship -4 ${NORMAL}, ${GREEN}--ipv4 ${NORMAL}          shows active interfaces with their IPv4 address"
  echo -e "  ${GREEN}ship -6 ${NORMAL}, ${GREEN}--ipv6 ${NORMAL}          shows active interfaces with their IPv6 address"
  echo -e "  ${GREEN}ship -a ${NORMAL}, ${GREEN}--all ${NORMAL}           shows basic info"
  echo -e "  ${GREEN}ship -d ${NORMAL}, ${GREEN}--driver ${NORMAL}        shows each active interface's driver"
  echo -e "  ${GREEN}ship -e ${NORMAL}, ${GREEN}--external ${NORMAL}<>    shows external IP addresses"
  echo -e "  ${GREEN}ship -f ${NORMAL}, ${GREEN}--find ${NORMAL}<>        shows valid IP and MAC addresses found on a file"
  echo -e "  ${GREEN}ship -g ${NORMAL}, ${GREEN}--gateway ${NORMAL}       shows gateway of online interfaces"
  echo -e "  ${CYAN}ship -H ${NORMAL}, ${CYAN}--help${NORMAL}, ${CYAN}help ${NORMAL}    shows this help message"
  echo -e "  ${_RED_}ship -h ${NORMAL}, ${_RED_}--hosts ${NORMAL}         shows active hosts on network"
  echo -e "  ${_RED_}ship -hm${NORMAL}, ${_RED_}--hosts-mac ${NORMAL}     shows active hosts on network with their MAC address"
  echo -e "  ${GREEN}ship -i ${NORMAL}, ${GREEN}--interfaces ${NORMAL}    shows active interfaces"
  echo -e "  ${GREEN}ship -m ${NORMAL}, ${GREEN}--mac ${NORMAL}           shows active interfaces with their MAC address"
  echo -e "  ${GREEN}ship -n ${NORMAL}, ${GREEN}--neighbor ${NORMAL}      shows neighbor cache"
  echo -e "  ${_RED_}ship -p ${NORMAL}, ${_RED_}--port ${NORMAL}<>        shows connections to a port per IP"
  echo -e "  ${GREEN}ship -r ${NORMAL}, ${GREEN}--route-ipv4 ${NORMAL}<>  shows the path to a network host using IPv4"
  echo -e "  ${GREEN}ship -r6${NORMAL}, ${GREEN}--route-ipv6 ${NORMAL}<>  shows the path to a network host using IPv6"
  echo -e "  ${GREEN}ship -u ${NORMAL}, ${GREEN}--url ${NORMAL}<>         shows valid IP and MAC addresses found on a website"
  echo -e "  ${GREEN}ship -v ${NORMAL}, ${GREEN}--version ${NORMAL}       shows the version of script"
  echo -e "  ${GREEN}ship --cidr-4${NORMAL}, ${GREEN}--cidr-ipv4 ${NORMAL}shows active interfaces with their IPv4 address and CIDR"
  echo -e "  ${GREEN}ship --cidr-6${NORMAL}, ${GREEN}--cidr-ipv6 ${NORMAL}shows active interfaces with their IPv6 address and CIDR"
  echo -e "  ${GREEN}ship --cidr-a${NORMAL}, ${GREEN}--cidr-all ${NORMAL} shows basic info with CIDR"
}

########################################################################
#                                                                      #
#  Helpful functions to print or check, verify and test various things #
#                                                                      #
########################################################################

# Prints a message while checking a network host.
function print_check() {
  
  echo -ne "Checking ${GREEN}$1${NORMAL} ..."
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
    "--local") ip route | grep "^default" > /dev/null || error_exit "${DIALOG_NO_LOCAL_CONNECTION}" ;;
    "--internet") ping -q -c 1 -W "${LONG_TIMEOUT}" "${GOOGLE_DNS}" > /dev/null || error_exit "${DIALOG_NO_INTERNET}" ;;
  esac
}

# Checks if ipv6 module is loaded.
function check_ipv6() {
  
  cat < /proc/modules | grep -io ipv6 > /dev/null || error_exit "${_RED_}IPv6 ${NORMAL}unavailable. ${DIALOG_ABORTING}"
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

# Handle file creation.
function check_and_touch() {
  
  local FILENAME_SUFFIX
  
  FILENAME_SUFFIX="$1"
  
  if [[ ! -f "$1" ]]; then touch "${FILENAME_PREFIX}${FILENAME_SUFFIX}" 2> /dev/null; fi
}

# Checks for root privileges.
function check_root_permissions() {
  
  if [[ "$(id -u)" -ne "0" ]]; then
    error_exit "${GREEN}ship${NORMAL} requires ${_RED_}root${NORMAL} privileges for this action."
  fi
}

# Checks Bash version. Minimum is version 3.2.
function check_bash_version() {
  
  if [[ "${BASH_VERSINFO[0]}" -lt 3 ]] || [[ "${BASH_VERSINFO[1]}" -lt 2 ]]; then
    error_exit "You need at least bash-3.2 to set sail."
  fi
}

# Deletes every file that is created by this script. Usually in /tmp.
function mr_proper() {
  
  rm -rf ${FILENAME_PREFIX}* 2> /dev/null
}

# Traps INT and SIGTSTP.
function trap_handler() {
  
  local YESNO
  
  YESNO=""
  
  echo
  
	while [[ ! "${YESNO}" =~ ^[YyNn]$ ]]; do
		echo -ne "Exit? [y/n] "
    read -r YESNO 2> /dev/null
	done

	if [[ "${YESNO}" = "Y" ]]; then
		YESNO="y"
	elif [[ "${YESNO}" = "N" ]]; then
		YESNO="n"
	fi
  
	if [[ "${YESNO}" = "y" ]]; then
    handle_jobs
    mr_proper
    clear
    
    exit 0
  fi
}

# Used with zero parameters: exit 1.
# Used with one parameter  : echoes parameter, usually error dialogs.
# Used with two parameters : invalid option, then echoes first parameter, usually error dialogs.
function error_exit() {
  
  if [[ -z "$1" ]]; then
    clear_line
    
    mr_proper
    exit 1
  elif [[ -z "$2" ]]; then
    clear_line
    echo -e  "$1"
    
    mr_proper
    exit 1
  else
    clear_line
    echo -e  "${GREEN}ship${NORMAL}: invalid option '$2'" 
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
  
  trap trap_handler INT 2> /dev/null
  trap trap_handler SIGTSTP 2> /dev/null
  check_bash_version
  
  while :; do
    case "$1" in
            "-4"|"--ipv4") check_connectivity "--local"; show_ipv4; break ;;
            "-6"|"--ipv6") check_connectivity "--local"; show_ipv6; break ;;
            "-a"|"--all") check_connectivity "--local"; show_all; break ;;
            "-d"|"--driver") check_connectivity "--local"; show_driver; break ;;
            "-e"|"--external") check_connectivity "--internet"; show_ip_from "$2"; shift 2; break ;;
            "-f"|"--find") show_ips_from_file "$2"; shift 2; break ;;
            "-g"|"--gateway") check_connectivity "--local"; show_gateway; break ;;
            "-h"|"--hosts") check_connectivity "--internet"; show_live_hosts --normal; break ;;
           "-hm"|"--hosts-mac") check_connectivity "--internet"; show_live_hosts --mac; break ;;
            "-i"|"--interfaces") check_connectivity "--local"; show_interfaces; break ;;
            "-p"|"--port") check_connectivity "--internet"; show_port_connections "$2"; shift 2; break ;;
            "-r"|"--route-ipv4") check_connectivity "--internet"; show_next_hops --ipv4 "$2"; shift 2; break ;;
           "-r6"|"--route-ipv6") check_connectivity "--internet"; show_next_hops --ipv6 "$2"; shift 2; break ;;
            "-m"|"--mac") check_connectivity "--local"; show_mac; break ;;
            "-n"|"--neighbor") check_connectivity "--local"; show_neighbor_cache; break ;;
            "-u"|"--url") check_connectivity "--internet"; show_ips_from_url "$2"; shift 2; break ;;
            "-v"|"--version") show_version; break ;;
      "--cidr-4"|"--cidr-ipv4") check_connectivity "--local"; show_ipv4_cidr; break ;;
      "--cidr-6"|"--cidr-ipv6") check_connectivity "--local"; show_ipv6_cidr; break ;;
      "--cidr-a"|"--cidr-all") check_connectivity "--local"; show_all_cidr; break ;;
            "-H"|"--help"|"help") show_usage; break ;;
      *) error_exit "${DIALOG_ERROR}" "$1"; break ;;
    esac
  done
  
  exit 0
}

sail "$1" "$2"
