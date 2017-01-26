#!/usr/bin/env bash -e
#### Description......: Show IPv4, IPv6 and MAC addresses, and many more.
#### Written by.......: Sotirios Roussis (aka. xtonousou) - xtonousou@gmail.com on 10-2016
#### Known limitations: ipinfo.io offers free 1,000 daily requests. (ship -f)

### Debugging
#set -o xtrace

### INFO
AUTHOR="Sotirios Roussis"
AUTHOR_NICKNAME="xtonousou"
GMAIL="${AUTHOR_NICKNAME}@gmail.com"
GITHUB="https://github.com/${AUTHOR_NICKNAME}"
SCRIPT_NAME="${0%.*}"
VERSION="2.3"

### Colors
COLORS=(
  "\e[1;0m"     # Normal ## COLORS[0]
  "\033[1;31m"  # Red    ## COLORS[1]
  "\033[1;32m"  # Green  ## COLORS[2]
  "\033[1;33m"  # Orange ## COLORS[3]
  "\033[1;36m"  # Cyan   ## COLORS[4]
)

### Locations
TEMP="/tmp"
GOOGLE_DNS="8.8.8.8"
IPINFO="ipinfo.io"

### Timeouts
SHORT_TIMEOUT="2"
TIMEOUT="5"
LONG_TIMEOUT="15"

### Dialogs
DIALOG_PRESS_CTRL_C="Press [CTRL+C] to stop"
DIALOG_ERROR="Try ${SCRIPT_NAME} ${COLORS[2]}-h${COLORS[0]} or ${SCRIPT_NAME} ${COLORS[2]}--help${COLORS[0]} for more information."
DIALOG_ABORTING="${COLORS[1]}Aborting${COLORS[0]}."
DIALOG_NO_INTERNET="Internet connection unavailable. ${DIALOG_ABORTING}"
DIALOG_NO_LOCAL_CONNECTION="Local connection unavailable. ${DIALOG_ABORTING}"
DIALOG_DESTINATION_UNREACHABLE="Destination is unreachable. ${DIALOG_ABORTING}"
DIALOG_SERVER_IS_DOWN="Destination is unreachable. Server may be down or has connection issues. ${DIALOG_ABORTING}"
DIALOG_NOT_A_NUMBER="Option should be integer. ${DIALOG_ABORTING}"
DIALOG_NO_ARGUMENTS="No arguments. ${DIALOG_ABORTING}"
DIALOG_NO_TRACEPATH6="${COLORS[3]}tracepath6${COLORS[0]} is missing, will use ${COLORS[3]}tracepath${COLORS[0]} with no IPv6 compatibility"
DIALOG_NO_TRACE_COMMAND="You must install at least one of the following tools to perform this action: ${COLORS[3]}tracepath${COLORS[0]}, ${COLORS[3]}traceroute${COLORS[0]}, ${COLORS[3]}mtr${COLORS[0]}. ${DIALOG_ABORTING}"
DIALOG_NO_IPTABLES="You must install ${COLORS[3]}iptables${COLORS[0]} to perform this action. ${DIALOG_ABORTING}"

########################################################################
#                                                                      #
#  Helpful functions to print or check, verify and test various things #
#                                                                      #
########################################################################

# Initializes a set of regexps variables (IPv4, IPv6, with and without CIDR).
function init_regexes() {

  # MAC
  REGEX_MAC="([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}"

  # IPv4
  REGEX_IPV4="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|"
  REGEX_IPV4+="(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"

  # IPv4 with CIDR notation
  REGEX_IPV4_CIDR="(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|"
  REGEX_IPV4_CIDR+="25[0-5])\.){3}([0-9]|""[1-9][0-9]|1[0-9]{2}|"
  REGEX_IPV4_CIDR+="2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))"

  # IPv6
  REGEX_IPV6="([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|"
  REGEX_IPV6+="([0-9a-fA-F]{1,4}:){1,7}:|"
  REGEX_IPV6+="([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|"
  REGEX_IPV6+="([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|"
  REGEX_IPV6+="([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|"
  REGEX_IPV6+="([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|"
  REGEX_IPV6+="([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|"
  REGEX_IPV6+="[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|"     
  REGEX_IPV6+=":((:[0-9a-fA-F]{1,4}){1,7}|:)|"
  # link-local IPv6 addresses with zone index
  REGEX_IPV6+="fe08:(:[0-9a-fA-F]{1,4}){2,2}%[0-9a-zA-Z]{1,}|"
  # IPv4-mapped IPv6 addresses and IPv4-translated addresses
  REGEX_IPV6+="::(ffff(:0{1,4}){0,1}:){0,1}${REGEX_IPV4}|"
  # IPv4-Embedded IPv6 Address
  REGEX_IPV6+="([0-9a-fA-F]{1,4}:){1,4}:${REGEX_IPV4}"

  # IPv6 with CIDR notation
  REGEX_IPV6_CIDR="^s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|"
  REGEX_IPV6_CIDR+=":))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|"
  REGEX_IPV6_CIDR+="2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|"
  REGEX_IPV6_CIDR+="1dd|[1-9]?d)){3})|:))|"
  REGEX_IPV6_CIDR+="(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|"
  REGEX_IPV6_CIDR+=":((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|"
  REGEX_IPV6_CIDR+="2[0-4]d|1dd|[1-9]?d)){3})|:))|"
  REGEX_IPV6_CIDR+="(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|"
  REGEX_IPV6_CIDR+="((:[0-9A-Fa-f]{1,4})?:((25[0-5]|"
  REGEX_IPV6_CIDR+="2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|"
  REGEX_IPV6_CIDR+="2[0-4]d|1dd|[1-9]?d)){3}))|:))|"
  REGEX_IPV6_CIDR+="(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|"
  REGEX_IPV6_CIDR+="((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|"
  REGEX_IPV6_CIDR+="[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|"
  REGEX_IPV6_CIDR+="(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|"
  REGEX_IPV6_CIDR+="((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|"
  REGEX_IPV6_CIDR+="[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|"
  REGEX_IPV6_CIDR+=":))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|"
  REGEX_IPV6_CIDR+="((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|"
  REGEX_IPV6_CIDR+="[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|"
  REGEX_IPV6_CIDR+="[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|"
  REGEX_IPV6_CIDR+="((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|"
  REGEX_IPV6_CIDR+="[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|"
  REGEX_IPV6_CIDR+=":)))(%.+)?s*(\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8]))?$"
}

# Prints a message while checking a network host.
function print_check() {
  
  echo -ne "Checking ${COLORS[2]}$1${COLORS[0]} ..."
}

# Clears previous line.
function clear_line() {
  
  printf "\r\033[K"
}

# Prints a list of most common ports with protocols.
function print_port_protocol_list() {

  declare PORTS_ARRAY
  declare PORTS_TCP_UDP_ARRAY
  declare PORTS_PROTOCOL_ARRAY
  
  PORTS_ARRAY=("20-21" "22" "23" "25" "53" "67-68" "69" "80" "110" "123" "137-139" "143" "161-162" "179" "389" "443" "636" "989-990")
  PORTS_TCP_UDP_ARRAY=("TCP" "TCP" "TCP" "TCP" "TCP/UDP" "UDP" "UDP" "TCP" "TCP" "UDP" "TCP/UDP" "TCP" "TCP/UDP" "TCP" "TCP/UDP" "TCP" "TCP/UDP" "TCP")
  PORTS_PROTOCOL_ARRAY=("FTP" "SSH" "Telnet" "SMTP" "DNS" "DHCP" "TFTP" "HTTP" "POPv3" "NTP" "NetBIOS" "IMAP" "SNMP" "BGP" "LDAP" "HTTPS" "LDAPS" "FTP over TLS/SSL")
  
  for i in "${!PORTS_ARRAY[@]}"; do
    printf "%-17s%-8s%s\n" "${PORTS_PROTOCOL_ARRAY[i]}" "${PORTS_TCP_UDP_ARRAY[i]}" "${PORTS_ARRAY[i]}"
  done
}

# Checks network connection (local or internet).
function check_connectivity() {
  
  case "${1}" in
    "--local")
      ip route | grep "^default" &>/dev/null || error_exit "${DIALOG_NO_LOCAL_CONNECTION}"
    ;;
    "--internet")
      ping -q -c 1 -W "${LONG_TIMEOUT}" "${GOOGLE_DNS}" &>/dev/null || error_exit "${DIALOG_NO_INTERNET}"
    ;;
  esac
}

# Exits ship, if ping fails to reach $1 in an amount of time.
function check_destination() {

  local RETURNED_VALUE
  local CLEAN_DESTINATION

  CLEAN_DESTINATION=$(echo "${1}" | sed 's/^http\(\|s\):\/\///g' | cut --fields=1 --delimiter="/")

  timeout "${SHORT_TIMEOUT}" ping -q -c 1 "${CLEAN_DESTINATION}" &>/dev/null || RETURNED_VALUE="${?}"

  if [[ "${RETURNED_VALUE}" -ge 2 ]]; then
    error_exit "${DIALOG_DESTINATION_UNREACHABLE}"
  else
    return
  fi
}

# Checks if ipv6 module is loaded.
function check_ipv6() {
  
  grep --ignore-case "ipv6" "/proc/modules" &> /dev/null && error_exit "${COLORS[1]}IPv6 ${COLORS[0]}unavailable. ${DIALOG_ABORTING}"
}

# Checks if an argument is passed, if not exit.
# $1=error message, $2=argument
function check_for_missing_args() {

  if [[ -z "${2}" ]]; then error_exit "${1}"; fi
}

# Verifies parameter to be number.
function check_if_parameter_is_not_numerical() {
  
  case "${1}" in ''|*[!0-9]*) error_exit "${DIALOG_NOT_A_NUMBER}" "${1}";; esac
}

# Checks for root privileges.
function check_root_permissions() {
  
  if [[ "$(id -u)" -ne 0 ]]; then
    error_exit "${COLORS[2]}${SCRIPT_NAME}${COLORS[0]} requires ${COLORS[1]}root${COLORS[0]} privileges for this action."
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
  
  rm --recursive --force "${TEMP}/${SCRIPT_NAME}"* &>/dev/null
}

# Traps INT and SIGTSTP.
function trap_handler() {
  
  local YESNO
  
  YESNO=""
  
  echo
  
	while [[ ! "${YESNO}" =~ ^[YyNn]$ ]]; do
		echo -ne "Exit? [y/n] "
    read -r YESNO &>/dev/null
	done

	if [[ "${YESNO}" = "Y" ]]; then
		YESNO="y"
	elif [[ "${YESNO}" = "N" ]]; then
		YESNO="n"
	fi
  
	if [[ "${YESNO}" = "y" ]]; then
    clear
    handle_jobs
    mr_proper
    
    exit 0
  fi
}

# Used with zero parameters: exit 1.
# Used with one parameter  : echoes parameter, usually error dialogs.
# Used with two parameters : invalid option, then echoes first parameter, usually error dialogs.
function error_exit() {
  
  if [[ -z "${1}" ]]; then
    clear_line
    
    mr_proper
    exit 1
  elif [[ -z "${2}" ]]; then
    clear_line
    echo -e  "${1}"
    
    mr_proper
    exit 1
  else
    clear_line
    echo -e  "${SCRIPT_NAME}: invalid option '${2}'" 
    echo -e  "${1}"

    mr_proper
    exit 1
  fi
}

# Background tasks' handeler.
function handle_jobs() {
  
  local JOB
  
  for JOB in $(jobs -p); do wait "${JOB}"; done
}

########################################################################
#                                                                      #
#  Main script's functions in alphabetical order based on show_usage() #
#                                                                      #
########################################################################

# Prints active network interfaces with their IPv4 address.
function show_ipv4() {
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))
  declare IPV4_ARRAY=($(ip address show | awk '/inet/ {print $2}' | cut --delimiter="/" --fields=1 | tail --lines=+2))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    echo "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done
}

# Prints active network interfaces with their IPv6 address.
function show_ipv6() {
  
  check_ipv6
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))
  declare IPV6_ARRAY=($(ip address show | awk 'tolower($0) ~ /inet6/{print $2}' | cut --delimiter="/" --fields=1 | tail --lines=+2 | awk '{print toupper($0)}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    echo "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done
}

# Prints all "basic" info.
function show_all() {
  
  local MAC_OF
  local DRIVER_OF
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))
  declare IPV4_ARRAY=($(ip address show | awk '/inet/ {print $2}' | cut --delimiter="/" --fields=1 | tail --lines=+2))
  declare IPV6_ARRAY=($(ip address show | awk 'tolower($0) ~ /inet6/{print $2}' | cut --delimiter="/" --fields=1 | tail --lines=+2 | awk '{print toupper($0)}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    if [[ -f "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent" ]]; then
      DRIVER_OF=$(awk --field-separator="=" '/^[DdRrIiVvEeRr]/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent")
    else
      DRIVER_OF=$(awk --field-separator="=" '/^[DdRrIiVvEeRr]/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/device/uevent")
    fi
    MAC_OF=$(awk '{print toupper($0)}' "/sys/class/net/${INTERFACES_ARRAY[i]}/address" 2> /dev/null)
    if grep --ignore-case "ipv6" "/proc/modules" &>/dev/null; then
      echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" "${MAC_OF}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
    else
      echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" "${MAC_OF}" "${IPV4_ARRAY[i]}"
    fi
  done
}

# Prints the driver used of active interface.
function show_driver() {
  
  local DRIVER_OF
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    if [[ -f "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent" ]]; then
      DRIVER_OF=$(awk --field-separator="=" '/^[DdRrIiVvEeRr]/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent")
    else
      DRIVER_OF=$(awk --field-separator="=" '/^[DdRrIiVvEeRr]/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/device/uevent")
    fi
    echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" 
  done
}

# Prints the external IP address/es. If $1 is empty prints user's public IP, if not, $1 should be like example.com.
function show_ip_from() {
  
  local HTTP_CODE
  local TEMP_FILE
  
  if [[ -z "${1}" ]]; then
    print_check "${IPINFO}"
    HTTP_CODE=$(wget --spider --tries=1 --timeout="${TIMEOUT}" --server-response "${IPINFO}" 2>&1 | awk '/HTTP\//{print $2}' | tail --lines=1)
    
    if [[ ! "${HTTP_CODE}" -eq 200 ]]; then error_exit "${DIALOG_SERVER_IS_DOWN}"; fi

    clear_line
    TEMP_FILE=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
    
    echo -ne "Grabbing ${COLORS[2]}IP${COLORS[0]} ..."
    wget "${IPINFO}/ip" --quiet --output-document="${TEMP_FILE}"
    
    clear_line
    awk '{print $0}' "${TEMP_FILE}"
  else
    print_check "${1}"
    check_destination "${1}"

    clear_line
    TEMP_FILE=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
    INPUT=$(echo "${1}" | sed 's/^http\(\|s\):\/\///g' | cut --fields=1 --delimiter="/")
  
    echo -ne "Pinging ${COLORS[2]}$1${COLORS[0]} ..."
    for i in {1..25}; do
      ping -c 1 -w "${LONG_TIMEOUT}" "${INPUT}" 2> /dev/null | awk --field-separator='[()]' '/PING/{print $2}' >> "${TEMP_FILE}" &
    done
    handle_jobs
  
    clear_line
    awk '{print $0}' "${TEMP_FILE}" | sort --version-sort --unique
  fi
}

# TODO NEEDS FIXING CANNOT PASS ARGUMENTS FROM sail();
# Prints all valid IPv4, IPv6 and MAC addresses extracted from file.
function show_ips_from_file() {
    
  #if [[ -z "$1" ]]; then error_exit "No file was specified. ${DIALOG_ABORTING}"; fi
  #if [[ ! -f "${1}" ]]; then error_exit "No such file. ${DIALOG_ABORTING}"; fi
  
  local TEMP_FILE_ONE
  local TEMP_FILE_TWO
  local TEMP_FILE_THREE
  local IS_TEMP_FILE_ONE_EMPTY
  local IS_TEMP_FILE_TWO_EMPTY
  local IS_TEMP_FILE_THREE_EMPTY

  TEMP_FILE_ONE=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
  TEMP_FILE_TWO=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
  TEMP_FILE_THREE=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)

  init_regexes

  for FILE; do
  echo $FILE
  
    grep --extended-regexp --only-matching "${REGEX_IPV4}" "${FILE}" 2>/dev/null | sort --version-sort --unique >> "${TEMP_FILE_ONE}"
    grep --extended-regexp --only-matching "${REGEX_IPV6}" "${FILE}" 2>/dev/null | sort --version-sort --unique >> "${TEMP_FILE_TWO}"
    grep --extended-regexp --only-matching "${REGEX_MAC}"  "${FILE}" 2>/dev/null | sort --version-sort --unique >> "${TEMP_FILE_THREE}"

    if [[ -s "${TEMP_FILE_ONE}" ]]; then IS_TEMP_FILE_ONE_EMPTY=0; else IS_TEMP_FILE_ONE_EMPTY=1; fi
    if [[ -s "${TEMP_FILE_TWO}" ]]; then IS_TEMP_FILE_TWO_EMPTY=0; else IS_TEMP_FILE_TWO_EMPTY=1; fi
    if [[ -s "${TEMP_FILE_THREE}" ]]; then IS_TEMP_FILE_THREE_EMPTY=0; else IS_TEMP_FILE_THREE_EMPTY=1; fi

    case "${IS_TEMP_FILE_ONE_EMPTY}:${IS_TEMP_FILE_TWO_EMPTY}:${IS_TEMP_FILE_THREE_EMPTY}" in
      0:0:0) # IPv4, IPv6 and MAC addresses
        paste "${TEMP_FILE_ONE}" "${TEMP_FILE_TWO}" "${TEMP_FILE_THREE}" | awk --field-separator='\t' '{printf("%-16s%-40s%s\n", $1, $2, $3)}'
      ;;
      0:0:1) # Only IPv4 and IPv6 addresses
        paste "${TEMP_FILE_ONE}" "${TEMP_FILE_TWO}" | awk --field-separator='\t' '{printf("%-16s%s\n", $1, $2)}' 
      ;;
      0:1:0) # Only IPv4 and MAC addresses
        paste "${TEMP_FILE_ONE}" "${TEMP_FILE_THREE}" | awk --field-separator='\t' '{printf("%-16s%s\n", $1, $2)}'
      ;;
      0:1:1) # Only IPv4 addresses
        paste "${TEMP_FILE_ONE}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
      ;;
      1:0:0) # Only IPv6 and MAC addresses
        paste "${TEMP_FILE_TWO}" "${TEMP_FILE_THREE}" | awk --field-separator='\t' '{printf("%-40s%s\n", $1, $2)}'
      ;;
      1:0:1) # Only IPv6 addresses
        paste "${TEMP_FILE_TWO}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
      ;;
      1:1:0) # Only MAC addresses
        paste "${TEMP_FILE_THREE}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
      ;;
      1:1:1) # None
        error_exit "No valid IPv4, IPv6 or MAC addresses found. ${DIALOG_ABORTING}"
      ;;
    esac
  done
  
  mr_proper
}

# Prints active network interfaces and their gateway.
function show_gateway() {
  
  local GATEWAY
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(ip route | awk '/${INTERFACES_ARRAY[i]}/ && /^default/ {print $3}')
    echo "${INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done
}

# Scans live hosts on network and prints their IPv4 address with or without MAC address. ICMP and ARP.
function show_live_hosts() {
  
  check_root_permissions
  
  local ONLINE_INTERFACE
  local NETWORK_IP
  local NETWORK_IP_CIDR
  local FILTERED_IP
  
  ONLINE_INTERFACE=$(ip route get "${GOOGLE_DNS}" | awk --field-separator="dev " 'NR == 1 {split($2, a, " "); print a[1]}')
  NETWORK_IP=$(ip route | awk "/${ONLINE_INTERFACE}/ && /src/ {print \$1}" | cut --fields=1 --delimiter="/")
  NETWORK_IP_CIDR=$(ip route | awk "/${ONLINE_INTERFACE}/ && /src/ {print \$1}")
  FILTERED_IP=$(echo "${NETWORK_IP}" | awk 'BEGIN{FS=OFS="."} NF--')
  
  ip -statistics neighbour flush all &>/dev/null
  
  echo -ne "Pinging ${COLORS[2]}${NETWORK_IP_CIDR}${COLORS[0]}, please wait ..."
  for i in {1..254}; do
    ping "${FILTERED_IP}.${i}" -c 1 -w "${LONG_TIMEOUT}" &>/dev/null &
  done
  handle_jobs
  
  clear_line

  init_regexes
  
  case "$1" in
    "--normal")
      ip neighbour | awk 'tolower($0) ~ /reachable|stale|delay|probe/{print $1}' | sort --version-sort --unique
    ;;
    "--mac")      
      ip neighbour | awk 'tolower($0) ~ /reachable|stale|delay|probe/{printf ("%5s\t%s\n", $1, toupper($5))}' | sort --version-sort --unique
    ;;
  esac
}

# Prints active network interfaces.
function show_interfaces() {

  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))

  echo "${INTERFACES_ARRAY[@]}"
}

# Prints connections and the count of them per IP.
function show_port_connections() {
  
  local PORT
  
  if [[ -z "$1" ]]; then print_port_protocol_list; exit 0; fi
  
  check_root_permissions
  check_if_parameter_is_not_numerical "$1"
  
  PORT="$1"
  
  clear
  while :; do
    clear
    echo -e "${DIALOG_PRESS_CTRL_C}"
    echo
    echo -e "      ${COLORS[2]}┌─> ${COLORS[1]}Count Port ${COLORS[2]}──┐"
    echo -e "      │ ┌───────> ${COLORS[1]}IPv4 ${COLORS[2]}└─> ${COLORS[1]}${PORT}"
    echo -e "    ${COLORS[2]}┌─┘ └──────────────┐${COLORS[0]}"
    ss --numeric --processes | awk "/${PORT}/ && /${REGEX_IPV4}/ {print \$6}" | cut --delimiter=":" --fields=1 | uniq --count
    sleep 3
  done
}

# Prints hops to a destination. $1=--ipv4|--ipv6, $2=network destination.
function show_next_hops() {
  
  local FILTERED_INPUT
  local FILENAME
  local PROTOCOL
  local TRACEPATH_CMD
  local TRACEROUTE_CMD
  local MTR_CMD
  
  hash tracepath &>/dev/null && TRACEPATH_CMD=1 || TRACEPATH_CMD=0
  hash traceroute &>/dev/null && TRACEROUTE_CMD=1 || TRACEROUTE_CMD=0
  hash mtr &>/dev/null && MTR_CMD=1 || MTR_CMD=0

  check_for_missing_args "${DIALOG_NO_ARGUMENTS}" "${2}"
  
  FILTERED_INPUT=$(echo "${2}" | sed 's/^http\(\|s\):\/\///g' | cut --fields=1 --delimiter="/")
  FILENAME="next_hops_for_selected_host"
  check_and_touch "${FILENAME}"

  case "$1" in
    "--ipv4") PROTOCOL=4; ;;
    "--ipv6") check_ipv6; PROTOCOL=6; ;;
  esac

  print_check "$2"

  check_destination "${FILTERED_INPUT}"

  init_regexes

  clear_line
  echo -ne "Tracing path to ${COLORS[2]}${FILTERED_INPUT}${COLORS[0]} ..."
  # traceroute is deprecated, nevertheless it is preferred over all
  case "${TRACEPATH_CMD}:${TRACEROUTE_CMD}:${MTR_CMD}" in
    # If none of the tools (tracepath, traceroute, mtr) is installed
    0:0:0)
      echo -e "${DIALOG_NO_TRACE_COMMAND}"
    ;;
    # If it is installed 'mtr' only
    0:0:1)
      case "${PROTOCOL}" in
        4)
          mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        6)
          mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
      esac
    ;;
    # If it is installed 'traceroute' only
    0:1:0)
      case "${PROTOCOL}" in
        4)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        6)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
      esac
    ;;
    # If it is installed 'traceroute' and 'mtr' only
    0:1:1)
      case "${PROTOCOL}" in
        4)
           mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        6)
           mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
      esac
    ;;
    # If it is installed 'tracepath' only
    1:0:0)
      # tracepath6 workaround: Many linux distributions do not have tracepath6 (it is included in manpages tho :/)
      hash tracepath6 &>/dev/null && PROTOCOL=6 || (PROTOCOL="" && echo -e "${DIALOG_NO_TRACEPATH6}")

      case "${PROTOCOL}" in
        4)
          timeout "${SHORT_TIMEOUT}" tracepath"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | awk '{print $2}' | grep --extended-regexp --only-matching "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        6)
          timeout "${SHORT_TIMEOUT}" tracepath"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | awk '{print $2}' | grep --extended-regexp --only-matching "${REGEX_IPV6}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
      esac
    ;;
    # If it is installed 'tracepath' and 'mtr' only
    1:0:1)
      case "${PROTOCOL}" in
        4)
          mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        6)
          mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
      esac
    ;;
    # If it is installed 'tracepath' and 'traceroute' only
    1:1:0)
      case "${PROTOCOL}" in
        4)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        6)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
      esac
    ;;
    # If it is installed 'tracepath', 'traceroute' and 'mtr'
    1:1:1)
      case "${PROTOCOL}" in
        4)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
        6)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}" >> "${FILENAME_PREFIX}${FILENAME}"
        ;;
      esac
    ;;
  esac
  
  clear_line
  awk '{print $0}' "${FILENAME_PREFIX}${FILENAME}" | uniq
}

# TODO
function show_tables() {

  hash iptables &>/dev/null ||cd error_exit "${DIALOG_NO_IPTABLES}"

  local FILENAME

  declare -a ALLOWED_ARRAY
  declare -a BLOCKED_ARRAY

  init_regexes
  
  ALLOWED_ARRAY=($(iptables -L INPUT -v -n | awk 'tolower($0) ~ /accept/ {print $8}' | grep --extended-regexp --only-matching "${REGEX_IPV4_CIDR}|${REGEX_IPV6_CIDR}|${REGEX_MAC}"))

  FILENAME="iptables_all"
  check_and_touch "${FILENAME}"

  case "$1" in
    "--all")
      echo "Allowed" "Blocked"
      for i in "${!ALLOWED_ARRAY[@]}"; do
        echo "${ALLOWED_ARRAY[i]}"
      done
    ;;
  esac
}

# Prints active network interfaces with their MAC address.
function show_mac() {
  
  local MAC_OF
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(awk '{print toupper($0)}' "/sys/class/net/${INTERFACES_ARRAY[i]}/address" 2> /dev/null)
    echo "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
  done
}

# Shows neighbor table.
function show_neighbor_cache() {
  
  local FILENAME
  
  FILENAME="neighbors"
  check_and_touch "${FILENAME}"

  ip neigh | awk 'tolower($0) ~ /permanent|noarp|stale|reachable|incomplete|delay|probe/{printf ("%-16s%-20s%s\n", $1, toupper($5), $6)}' >> "${FILENAME_PREFIX}${FILENAME}"
  
  awk '{print $0}' "${FILENAME_PREFIX}${FILENAME}" | sort --version-sort
}

# Extracts valid IPv4, IPv6 and MAC addresses from a URL.
function show_ips_from_online_document() {

  check_for_missing_args "No URL was specified. ${DIALOG_ABORTING}" "${1}"
  
  local HTTP_CODE
  local FILENAME_HTML
  local FILENAME_IPV4
  local FILENAME_IPV6
  local FILENAME_MAC
  
  print_check "${1}"
  HTTP_CODE=$(wget --spider --tries 1 --timeout="${TIMEOUT}" --server-response "${1}" 2>&1 | awk '/HTTP\//{print $2}' | tail --lines=1)
  
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
  
  echo -ne "Downloading ${COLORS[2]}$1${COLORS[0]} ..."
  wget "$1" --quiet --output-document="${FILENAME_PREFIX}${FILENAME_HTML}"
  clear_line

  init_regexes

  grep --extended-regexp --only-matching "${REGEX_IPV4}" "${FILENAME_PREFIX}${FILENAME_HTML}" | sort --version-sort --unique >> "${FILENAME_PREFIX}${FILENAME_IPV4}"
  grep --extended-regexp --only-matching "${REGEX_IPV6}" "${FILENAME_PREFIX}${FILENAME_HTML}" | sort --version-sort --unique >> "${FILENAME_PREFIX}${FILENAME_IPV6}"
  grep --extended-regexp --only-matching "${REGEX_MAC}"  "${FILENAME_PREFIX}${FILENAME_HTML}" | sort --version-sort --unique >> "${FILENAME_PREFIX}${FILENAME_MAC}"
  
  if [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]]; then
  # if no valid addresses found, exit.
    error_exit "No valid IPv4, IPv6 or MAC addresses found. ${DIALOG_ABORTING}"
  elif [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then
  # if there are valid IPv4, IPv6 and MAC addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_IPV6}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk --field-separator='\t' '{printf("%-16s%-40s%s\n", $1, $2, toupper($3))}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then
  # if there are only                                                                        ^^^^addresses                                    ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_IPV6}" | awk --field-separator='\t' '{printf("%-16s%s\n", $1, $2)}' 
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then 
  # if there are only                                                                         ^^^addresses                                    ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV6}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk --field-separator='\t' '{printf("%-40s%s\n", $1, toupper($2))}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]]; then 
  # if there are only                                                                         ^^^addresses                                    ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" "${FILENAME_PREFIX}${FILENAME_MAC}" | awk --field-separator='\t' '{printf("%-16s%s\n", $1, toupper($2))}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]]; then
  # if there are only                                                                                                                           ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV4}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]]; then 
  # if there are only                                                                                                                           ^^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_IPV6}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
  elif [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV4}" ]] && [[ ! -s "${FILENAME_PREFIX}${FILENAME_IPV6}" ]] && [[ -s "${FILENAME_PREFIX}${FILENAME_MAC}" ]]; then
  # if there are only                                                                                                                            ^^^addresses...
    paste "${FILENAME_PREFIX}${FILENAME_MAC}" | awk --field-separator='\t' '{printf("%s\n", toupper($1))}'
  fi
}

# Prints script's version and author's info.
function show_version() {
  
  echo
  echo    "         _~"
  echo -e "      _~ )_)_~          Author .: ${COLORS[2]}${AUTHOR}${COLORS[0]}"
  echo -e "      )_))_))_)		Mail ...: ${COLORS[2]}${GMAIL}${COLORS[0]}"
  echo -e "      ${COLORS[3]}_!__!__!_${COLORS[0]}		Github .: ${COLORS[2]}${GITHUB}${COLORS[0]}"
  echo -e "      ${COLORS[3]}\_______/${COLORS[0]}         Version : ${COLORS[2]}${VERSION}${COLORS[0]}"
  echo -e "  ${COLORS[4]}~~~~~~~~~~~~~~~~~${COLORS[0]}"
}

# Prints active network interfaces with their IPv4 address and CIDR suffix.
function show_ipv4_cidr() {

  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))
  declare IPV4_CIDR_ARRAY=($(ip address show | awk '$1 ~ /inet$/{print $2}' | tail --lines=+2))
  
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    echo "${INTERFACES_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done
}

# Prints active network interfaces with their IPv6 address and CIDR suffix.
function show_ipv6_cidr() {
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))
  declare IPV6_CIDR_ARRAY=($(ip address show | awk '$1 ~ /inet6$/{print toupper($2)}' | tail --lines=+2))

  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    echo "${INTERFACES_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done
}

# Prints all info and CIDR suffix.
function show_all_cidr() {
  
  local MAC_OF
  local DRIVER_OF
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /^[DdEeFfAaUuLlTt]/ {print $5}'))
  declare IPV4_CIDR_ARRAY=($(ip address show | awk '$1 ~ /inet$/{print $2}' | tail --lines=+2))
  declare IPV6_CIDR_ARRAY=($(ip address show | awk '$1 ~ /inet6$/{print toupper($2)}' | tail --lines=+2))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    if [[ -f "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent" ]]; then
      DRIVER_OF=$(awk --field-separator="=" '/^[DdRrIiVvEeRr]/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent")
    else
      DRIVER_OF=$(awk --field-separator="=" '/^[DdRrIiVvEeRr]/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/device/uevent")
    fi
    MAC_OF=$(awk '{print toupper($0)}' "/sys/class/net/${INTERFACES_ARRAY[i]}/address" 2> /dev/null)
    if grep --ignore-case "ipv6" "/proc/modules" &>/dev/null; then
      echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" "${MAC_OF}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
    else
      echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" "${MAC_OF}" "${IPV4_CIDR_ARRAY[i]}"
    fi
  done
}

# Prints help message.
function show_usage() {
  
  echo    " usage: ${SCRIPT_NAME} [OPTION] <ARGUMENT>"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-4 ${COLORS[0]}, ${COLORS[2]}--ipv4 ${COLORS[0]}          shows active interfaces with their IPv4 address"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-6 ${COLORS[0]}, ${COLORS[2]}--ipv6 ${COLORS[0]}          shows active interfaces with their IPv6 address"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-a ${COLORS[0]}, ${COLORS[2]}--all ${COLORS[0]}           shows all basic info"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-d ${COLORS[0]}, ${COLORS[2]}--driver ${COLORS[0]}        shows each active interface's driver"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-e ${COLORS[0]}, ${COLORS[2]}--external ${COLORS[0]}<>    shows external IP addresses (pass no argument to show yours)"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-f ${COLORS[0]}, ${COLORS[2]}--find ${COLORS[0]}<>        shows valid IP and MAC addresses found on a file"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-g ${COLORS[0]}, ${COLORS[2]}--gateway ${COLORS[0]}       shows gateway of online interfaces"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-h ${COLORS[0]}, ${COLORS[2]}--help${COLORS[0]}           shows this help message"
  echo -e "  ${SCRIPT_NAME} ${COLORS[1]}-H ${COLORS[0]}, ${COLORS[1]}--hosts ${COLORS[0]}         shows active hosts on network"
  echo -e "  ${SCRIPT_NAME} ${COLORS[1]}-HM${COLORS[0]}, ${COLORS[1]}--hosts-mac ${COLORS[0]}     shows active hosts on network with their MAC address"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-i ${COLORS[0]}, ${COLORS[2]}--interfaces ${COLORS[0]}    shows active interfaces"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-m ${COLORS[0]}, ${COLORS[2]}--mac ${COLORS[0]}           shows active interfaces with their MAC address"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-n ${COLORS[0]}, ${COLORS[2]}--neighbor ${COLORS[0]}      shows neighbor cache"
  echo -e "  ${SCRIPT_NAME} ${COLORS[1]}-P ${COLORS[0]}, ${COLORS[1]}--port ${COLORS[0]}<>        shows connections to a port per IP (pass no argument to show common ports)"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-r ${COLORS[0]}, ${COLORS[2]}--route-ipv4 ${COLORS[0]}<>  shows the path to a network host using IPv4"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-r6${COLORS[0]}, ${COLORS[2]}--route-ipv6 ${COLORS[0]}<>  shows the path to a network host using IPv6"
  echo -e "  ${SCRIPT_NAME} ${COLORS[1]}-T ${COLORS[0]}, ${COLORS[1]}--tables ${COLORS[0]}        shows all allowed and blocked IP addresses"
  echo -e "  ${SCRIPT_NAME} ${COLORS[1]}-TA${COLORS[0]}, ${COLORS[1]}--tables-allowed${COLORS[0]} shows all allowed IP addresses"
  echo -e "  ${SCRIPT_NAME} ${COLORS[1]}-TB${COLORS[0]}, ${COLORS[1]}--tables-blocked ${COLORS[0]}shows all blocked IP addresses"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-u ${COLORS[0]}, ${COLORS[2]}--url ${COLORS[0]}<>         shows valid IP and MAC addresses found on a website"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}-v ${COLORS[0]}, ${COLORS[2]}--version ${COLORS[0]}       shows the version of script"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}--cidr-4${COLORS[0]}, ${COLORS[2]}--cidr-ipv4 ${COLORS[0]}shows active interfaces with their IPv4 address and CIDR"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}--cidr-6${COLORS[0]}, ${COLORS[2]}--cidr-ipv6 ${COLORS[0]}shows active interfaces with their IPv6 address and CIDR"
  echo -e "  ${SCRIPT_NAME} ${COLORS[2]}--cidr-a${COLORS[0]}, ${COLORS[2]}--cidr-all ${COLORS[0]} shows all basic info with CIDR"
  echo -e " options in ${COLORS[1]}red${COLORS[0]} require root privileges"
}

# Starts ship.
function sail() {
  
  if [[ -z "${1}" ]]; then error_exit "${DIALOG_ERROR}"; fi

  check_bash_version
  
  while :; do
    case "${1}" in
            "-4"|"--ipv4") check_connectivity "--local"; show_ipv4; break ;;
            "-6"|"--ipv6") check_connectivity "--local"; show_ipv6; break ;;
            "-a"|"--all") check_connectivity "--local"; show_all; break ;;
            "-d"|"--driver") check_connectivity "--local"; show_driver; break ;;
            "-e"|"--external") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_ip_from "$2"; shift 2; break ;;
            "-f"|"--find") trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_ips_from_file "${@:2}"; break ;;
            "-g"|"--gateway") check_connectivity "--local"; show_gateway; break ;;
            "-h"|"--help") show_usage; break ;;
            "-H"|"--hosts") check_connectivity "--local"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_live_hosts --normal; break ;;
           "-HM"|"--hosts-mac") check_connectivity "--local"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_live_hosts --mac; break ;;
            "-i"|"--interfaces") check_connectivity "--local"; show_interfaces; break ;;
            "-P"|"--port") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_port_connections "$2"; shift 2; break ;;
            "-r"|"--route-ipv4") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_next_hops --ipv4 "$2"; shift 2; break ;;
           "-r6"|"--route-ipv6") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_next_hops --ipv6 "$2"; shift 2; break ;;
            "-T"|"--tables") show_tables --all; break ;;
            "-TA"|"--tables-allowed") show_tables --allowed; break ;;
            "-TB"|"--tables-blocked") show_tables --blocked; break ;;
            "-m"|"--mac") check_connectivity "--local"; show_mac; break ;;
            "-n"|"--neighbor") check_connectivity "--local"; show_neighbor_cache; break ;;
            "-u"|"--url") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_ips_from_online_document "$2"; shift 2; break ;;
            "-v"|"--version") show_version; break ;;
      "--cidr-4"|"--cidr-ipv4") check_connectivity "--local"; show_ipv4_cidr; break ;;
      "--cidr-6"|"--cidr-ipv6") check_connectivity "--local"; show_ipv6_cidr; break ;;
      "--cidr-a"|"--cidr-all") check_connectivity "--local"; show_all_cidr; break ;;
      *) error_exit "${DIALOG_ERROR}" "$1"; break ;;
    esac
  done

  exit 0
}

sail "${@}"
