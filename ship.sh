#!/usr/bin/env bash
## Title........: ship.sh
## Description..: A simple, handy network addressing multitool with plenty of features.
## Author.......: Sotirios Roussis aka. xtonousou - xtonousou@gmail.com
## Date.........: 20160211
## Version......: 2.4
## Usage........: bash ship.sh
## Bash Version.: 3.2 or later
## Limitations..: ipinfo.io offers free 1,000 daily requests (ship -e)

### Debugging
#set -o xtrace

### Script's Info
readonly VERSION="2.4"
readonly SCRIPT_NAME="${0%.*}"

### Author's Info
readonly AUTHOR="Sotirios Roussis"
readonly AUTHOR_NICKNAME="xtonousou"
readonly GMAIL="${AUTHOR_NICKNAME}@gmail.com"
readonly GITHUB="https://github.com/${AUTHOR_NICKNAME}"

### Colors
declare -r COLORS=(
  "\e[1;0m"     # Normal  ## COLORS[0]
  "\033[1;31m"  # Red     ## COLORS[1]
  "\033[1;32m"  # Green   ## COLORS[2]
  "\033[1;33m"  # Orange  ## COLORS[3]
  "\033[1;36m"  # Cyan    ## COLORS[4]
  "\033[1;95m"  # Magenta ## COLORS[5]
)

### Locations
readonly TEMP="/tmp"
readonly GOOGLE_DNS="8.8.8.8"
readonly IPINFO="ipinfo.io"

### Timeouts
readonly SHORT_TIMEOUT="2"
readonly TIMEOUT="6"
readonly LONG_TIMEOUT="17"

### Dialogs
readonly DIALOG_PRESS_CTRL_C="Press [CTRL+C] to stop"
readonly DIALOG_ERROR="Try ${SCRIPT_NAME} ${COLORS[2]}-h${COLORS[0]} or ${SCRIPT_NAME} ${COLORS[2]}--help${COLORS[0]} for more information."
readonly DIALOG_ABORTING="${COLORS[1]}Aborting${COLORS[0]}."
readonly DIALOG_NO_INTERNET="Internet connection unavailable. ${DIALOG_ABORTING}"
readonly DIALOG_NO_LOCAL_CONNECTION="Local connection unavailable. ${DIALOG_ABORTING}"
readonly DIALOG_DESTINATION_UNREACHABLE="Destination is unreachable. ${DIALOG_ABORTING}"
readonly DIALOG_SERVER_IS_DOWN="Destination is unreachable. Server may be down or has connection issues. ${DIALOG_ABORTING}"
readonly DIALOG_NO_VALID_IPV4="The IPv4 address is invalid. ${DIALOG_ABORTING}"
readonly DIALOG_NO_VALID_IPV6="The IPv6 address is invalid. ${DIALOG_ABORTING}"
readonly DIALOG_NO_VALID_MASK="The netmask is invalid. ${DIALOG_ABORTING}"
readonly DIALOG_NO_VALID_CIDR="The CIDR is invalid. ${DIALOG_ABORTING}"
readonly DIALOG_NO_VALID_ADDRESSES="No valid IPv4, IPv6 or MAC addresses found. ${DIALOG_ABORTING}"
readonly DIALOG_NO_ARGUMENTS="No arguments. ${DIALOG_ABORTING}"
readonly DIALOG_NO_NETMASK="Netmask is missing. Usage: ${COLORS[5]}192.168.0.1/24${COLORS[0]} or ${COLORS[5]}192.168.0.1 255.255.128.0 ${DIALOG_ABORTING}"
readonly DIALOG_NO_TRACEPATH6="${COLORS[3]}tracepath6${COLORS[0]} is missing, will use ${COLORS[3]}tracepath${COLORS[0]} with no IPv6 compatibility"
readonly DIALOG_NO_TRACE_COMMAND="You must install at least one of the following tools to perform this action: ${COLORS[3]}tracepath${COLORS[0]}, ${COLORS[3]}traceroute${COLORS[0]}, ${COLORS[3]}mtr${COLORS[0]}. ${DIALOG_ABORTING}"

########################################################################
#                                                                      #
#  Helpful functions to print or check, verify and test various things #
#                                                                      #
########################################################################

# Initializes a set of regexps variables (IPv4, IPv6, with and without CIDR).
function init_regexes() {

  # MAC
  readonly REGEX_MAC="([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}"

  # IPv4
  readonly REGEX_IPV4="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"

  # IPv4 with CIDR notation
  readonly REGEX_IPV4_CIDR="(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|""[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))"

  # IPv6
  readonly REGEX_IPV6="([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe08:(:[0-9a-fA-F]{1,4}){2,2}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}${REGEX_IPV4}|([0-9a-fA-F]{1,4}:){1,4}:${REGEX_IPV4}"

  # IPv6 with CIDR notation
  readonly REGEX_IPV6_CIDR="^s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*(\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8]))?$"

  return 0
}

# Convert a decimal to binary.
function dec_to_bin() {

  declare D2B

  D2B=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})

  echo -n "${D2B[${1}]}"

  return 0
}

# Convert binary to a decimal.
function bin_to_dec() {

  echo "$((2#${1}))"

  return 0
}

# Convert a decimal to a hexadecimal.
function bin_to_hex() {

  printf '%x\n' "$((2#${1}))"

  return 0
}

# Prints a message while checking a network host.
function print_check() {
  
  echo -ne "Checking ${COLORS[2]}$1${COLORS[0]} ..."

  return 0
}

# Clears previous line.
function clear_line() {
  
  printf "\r\033[K"

  return 0
}

# Prints a list of most common ports with protocols.
function print_port_protocol_list() {
 
  declare -r PORTS_ARRAY=("20-21" "22" "23" "25" "53" "67-68" "69" "80" "110" "123" "137-139" "143" "161-162" "179" "389" "443" "636" "989-990")
  declare -r PORTS_TCP_UDP_ARRAY=("TCP" "TCP" "TCP" "TCP" "TCP/UDP" "UDP" "UDP" "TCP" "TCP" "UDP" "TCP/UDP" "TCP" "TCP/UDP" "TCP" "TCP/UDP" "TCP" "TCP/UDP" "TCP")
  declare -r PORTS_PROTOCOL_ARRAY=("FTP" "SSH" "Telnet" "SMTP" "DNS" "DHCP" "TFTP" "HTTP" "POPv3" "NTP" "NetBIOS" "IMAP" "SNMP" "BGP" "LDAP" "HTTPS" "LDAPS" "FTP over TLS/SSL")
  
  for i in "${!PORTS_ARRAY[@]}"; do
    printf "%-17s%-8s%s\n" "${PORTS_PROTOCOL_ARRAY[i]}" "${PORTS_TCP_UDP_ARRAY[i]}" "${PORTS_ARRAY[i]}"
  done

  return 0
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

  return 0
}

# Exits ship, if ping fails to reach $1 in an amount of time.
function check_destination() {

  local CLEAN_DESTINATION
  local RETURNED_VALUE

  CLEAN_DESTINATION=$(echo "${1}" | sed 's/^http\(\|s\):\/\///g' | cut --fields=1 --delimiter="/")

  timeout "${LONG_TIMEOUT}" ping -q -c 1 "${CLEAN_DESTINATION}" &>/dev/null || RETURNED_VALUE="${?}"

  if [[ "${RETURNED_VALUE}" -ge 2 ]]; then error_exit "${DIALOG_DESTINATION_UNREACHABLE}"; fi

  return 0
}

# Various check for CIDR validation.
function check_cidr() {

  case "${2}" in
    "ipv4")
      # check for non numerical CIDR
      if [[ ! "${1}" =~ ^[0-9]+$ ]]; then error_exit "${DIALOG_NO_VALID_CIDR}"; fi
      # if no CIDR is specified then pass the default value
      if [[ ! "${1}" ]]; then CIDR="24"; fi # default notation
      # check if cidr is < 0 or > 32
      if [[ "${1}" -lt 0 ]] || [[ "${1}" -gt 32 ]]; then error_exit "${DIALOG_NO_VALID_CIDR}"; fi
    ;;
    "ipv6") # MODIFY TO VALIDATE CIDR FOR IPV6
      # check for non numerical CIDR
      if [[ ! "${1}" =~ ^[0-9]+$ ]]; then error_exit "${DIALOG_NO_VALID_CIDR}"; fi
      # if no CIDR is specified then pass the default value
      if [[ ! "${1}" ]]; then CIDR="24"; fi # default notation
      # check if cidr is < 0 or > 32
      if [[ "${1}" -lt 0 ]] || [[ "${1}" -gt 32 ]]; then error_exit "${DIALOG_NO_VALID_CIDR}"; fi
    ;;
  esac
}

# Checks if ipv6 module is loaded.
function check_ipv6() {
  
  grep --ignore-case "ipv6" "/proc/modules" &> /dev/null || error_exit "${COLORS[1]}IPv6 ${COLORS[0]}unavailable. ${DIALOG_ABORTING}"

  return 0
}

# Checks if an argument is passed, if not exit.
# $1=error message, $2=argument
function check_for_missing_args() {

  if [[ -z "${2}" ]]; then error_exit "${1}"; fi

  return 0
}

# Numerical verification.
function check_if_parameter_is_not_numerical() {

  if [[ ! "${1}" =~ ^[0-9]+$ ]]; then
    error_exit "${1} is not integer. ${DIALOG_ABORTING}" "${1}"
  fi

  return 0
}

# Checks for root privileges.
function check_root_permissions() {
  
  if [[ "$(id -u)" -ne 0 ]]; then error_exit "${COLORS[2]}${SCRIPT_NAME}${COLORS[0]} requires ${COLORS[1]}root${COLORS[0]} privileges for this action."; fi

  return 0
}

# Checks Bash version. Minimum is version 3.2.
function check_bash_version() {
  
  if [[ "${BASH_VERSINFO[0]}" -lt 3 ]] || [[ "${BASH_VERSINFO[1]}" -lt 2 ]]; then error_exit "You need at least bash-3.2 to set sail."; fi

  return 0
}

# Deletes every file that is created by this script. Usually in /tmp.
function mr_proper() {

  # "${TEMP:?}" to ensure this never expands to /*
  rm --recursive --force "${TEMP:?}/${SCRIPT_NAME}"* &>/dev/null

  return 0
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
    
    exit 0
  fi

  return 0
}

# Used with zero parameters: exit 1.
# Used with one parameter  : echoes parameter, usually error dialogs.
# Used with two parameters : invalid option, then echoes first parameter, usually error dialogs.
function error_exit() {
  
  if [[ -z "${1}" ]]; then
    clear_line
    exit 1
  elif [[ -z "${2}" ]]; then
    clear_line
    echo -e "${1}"
    exit 1
  else
    clear_line
    echo -e "${SCRIPT_NAME}: invalid option '${2}'" 
    echo -e "${1}"
    exit 1
  fi
}

# Background tasks' handler.
function handle_jobs() {
  
  local JOB
  
  for JOB in $(jobs -p); do wait "${JOB}"; done

  return 0
}

########################################################################
#                                                                      #
#  Main script's functions in alphabetical order based on show_usage() #
#                                                                      #
########################################################################

# Prints active network interfaces with their IPv4 address.
function show_ipv4() {
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))
  declare IPV4_ARRAY=($(ip address show | awk '/inet/ {print $2}' | cut --delimiter="/" --fields=1 | tail --lines=+2))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    echo "${INTERFACES_ARRAY[i]}" "${IPV4_ARRAY[i]}"
  done

  return 0
}

# Prints active network interfaces with their IPv6 address.
function show_ipv6() {
  
  check_ipv6
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))
  declare IPV6_ARRAY=($(ip address show | awk 'tolower($0) ~ /inet6/{print $2}' | cut --delimiter="/" --fields=1 | tail --lines=+2 | awk '{print toupper($0)}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    echo "${INTERFACES_ARRAY[i]}" "${IPV6_ARRAY[i]}"
  done

  return 0
}

# Prints all "basic" info.
function show_all() {
  
  local MAC_OF
  local DRIVER_OF
  local GATEWAY
  local IFS
  local DECIMAL_POINTS
  local BITS
  local HOST_BITS
  local HOST_BITS_MASK_BINARY
  local IP
  local IP_BINARY
  local NETMASK
  local NETMASK_BINARY
  local WILDCARD
  local WILDCARD_BINARY
  local NETWORK_ADDRESS
  local NETWORK_ADDRESS_BINARY
  local BROADCAST_ADDRESS
  local BROADCAST_ADDRESS_BINARY
  local IP_PART_A
  local IP_PART_B
  local IP_PART_C
  local IP_PART_D
  local NETMASK_PART_A
  local NETMASK_PART_B
  local NETMASK_PART_C
  local NETMASK_PART_D
  local PART_A
  local PART_B
  local PART_C
  local PART_D
  local CIDR
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))
  declare IPV4_ARRAY=($(ip address show | awk '/inet/ {print $2}' | cut --delimiter="/" --fields=1 | tail --lines=+2))
  declare IPV6_ARRAY=($(ip address show | awk 'tolower($0) ~ /inet6/{print $2}' | cut --delimiter="/" --fields=1 | tail --lines=+2 | awk '{print toupper($0)}'))

  if [[ -z "${1}" ]]; then  
    for i in "${!INTERFACES_ARRAY[@]}"; do
      if [[ -f "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent" ]]; then
        DRIVER_OF=$(awk --field-separator="=" 'tolower($0) ~ /driver/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent")
      else
        DRIVER_OF=$(awk --field-separator="=" 'tolower($0) ~ /driver/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/device/uevent")
      fi
      MAC_OF=$(awk '{print toupper($0)}' "/sys/class/net/${INTERFACES_ARRAY[i]}/address" 2> /dev/null)
      GATEWAY=$(ip route | awk "/${INTERFACES_ARRAY[i]}/ && tolower(\$0) ~ /default/ {print \$3}")
      if grep --ignore-case "ipv6" "/proc/modules" &>/dev/null; then
        echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" "${MAC_OF}" "${GATEWAY}" "${IPV4_ARRAY[i]}" "${IPV6_ARRAY[i]}"
      else
        echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" "${MAC_OF}" "${GATEWAY}" "${IPV4_ARRAY[i]}"
      fi
    done
  else
    init_regexes

    IP=$(echo "${1}" | grep --extended-regexp --only-matching "${REGEX_IPV4}")

    # if ipv4/cidr
    if echo "${1}" | grep --extended-regexp --only-matching "${REGEX_IPV4_CIDR}" &> /dev/null; then
      CIDR=$(echo "${1}" | awk --field-separator='/' '{print $2}')
      check_cidr "${CIDR}" "ipv4"

      NETMASK=$(( 0xffffffff ^ (( 1 << ( 32 - CIDR )) -1 ) ))
      NETMASK=$(( ( NETMASK >> 24 ) & 0xff )).$(( ( NETMASK >> 16 ) & 0xff )).$(( ( NETMASK >> 8 ) & 0xff )).$(( NETMASK & 0xff ))

      IFS=.
      read NETMASK_PART_A NETMASK_PART_B NETMASK_PART_C NETMASK_PART_D <<< "${NETMASK}"
      NETMASK_BINARY="$(dec_to_bin ${NETMASK_PART_A}).$(dec_to_bin ${NETMASK_PART_B}).$(dec_to_bin ${NETMASK_PART_C}).$(dec_to_bin ${NETMASK_PART_D})"
    # if only ipv4 and no CIDR
    elif echo "${1}" | grep --extended-regexp --only-matching "${REGEX_IPV4}" &> /dev/null; then
      # if no netmask was specified keep the default value
      if [[ -z "${2}" ]]; then NETMASK="255.255.255.0"; else NETMASK="${2}"; fi
      DECIMAL_POINTS=$(echo "${NETMASK}" | grep --only-matching "\\." | wc --lines)
      # check if there are three dots
      if [[ "${DECIMAL_POINTS}" != 3 ]]; then error_exit "${DIALOG_NO_VALID_MASK}"; fi
      
      IFS=.
      read NETMASK_PART_A NETMASK_PART_B NETMASK_PART_C NETMASK_PART_D <<< "${NETMASK}"
      
      # check if any part is empty
      if [[ ! "${NETMASK_PART_A}" ]] || [[ ! "${NETMASK_PART_B}" ]] || [[ ! "${NETMASK_PART_C}" ]] || [[ ! "${NETMASK_PART_D}" ]]; then
        error_exit "${DIALOG_NO_VALID_MASK}"
      # check if any part of netmask is < 0 or > 255
      elif [[ "${NETMASK_PART_A}" -lt 0 ]] || [[ "${NETMASK_PART_A}" -gt 255 ]] ||
         [[ "${NETMASK_PART_B}" -lt 0 ]] || [[ "${NETMASK_PART_B}" -gt 255 ]] ||
         [[ "${NETMASK_PART_C}" -lt 0 ]] || [[ "${NETMASK_PART_C}" -gt 255 ]] ||
         [[ "${NETMASK_PART_D}" -lt 0 ]] || [[ "${NETMASK_PART_D}" -gt 255 ]]; then
          error_exit "${DIALOG_NO_VALID_MASK}"
      fi
      
      NETMASK_BINARY="$(dec_to_bin ${NETMASK_PART_A}).$(dec_to_bin ${NETMASK_PART_B}).$(dec_to_bin ${NETMASK_PART_C}).$(dec_to_bin ${NETMASK_PART_D})"
      CIDR=$(echo "${NETMASK_BINARY}" | grep --only-matching 1 | wc --lines)
    fi
    
    read IP_PART_A IP_PART_B IP_PART_C IP_PART_D <<< "${IP}"
    IP_BINARY="$(dec_to_bin ${IP_PART_A}).$(dec_to_bin ${IP_PART_B}).$(dec_to_bin ${IP_PART_C}).$(dec_to_bin ${IP_PART_D})"
    
    WILDCARD_BINARY=$(echo "${NETMASK_BINARY}" | tr 01 10)
    read PART_A PART_B PART_C PART_D <<< "${WILDCARD_BINARY}"

    IFS=

    WILDCARD="$(bin_to_dec ${PART_A}).$(bin_to_dec ${PART_B}).$(bin_to_dec ${PART_C}).$(bin_to_dec ${PART_D})"
    NETWORK_ADDRESS=$(( IP_PART_A & NETMASK_PART_A )).$(( IP_PART_B & NETMASK_PART_B )).$(( IP_PART_C & NETMASK_PART_C )).$(( IP_PART_D & NETMASK_PART_D ))
    PART_A=$(echo "${NETWORK_ADDRESS}" | cut --delimiter='.' --fields=1); PART_B=$(echo "${NETWORK_ADDRESS}" | cut --delimiter='.' --fields=2)
    PART_C=$(echo "${NETWORK_ADDRESS}" | cut --delimiter='.' --fields=3); PART_D=$(echo "${NETWORK_ADDRESS}" | cut --delimiter='.' --fields=4)

    NETWORK_ADDRESS_BINARY="$(dec_to_bin ${PART_A}).$(dec_to_bin ${PART_B}).$(dec_to_bin ${PART_C}).$(dec_to_bin ${PART_D})"
    
    HOST_BITS=$(echo "${NETMASK_BINARY}" | grep --only-matching 0 | wc --lines)

    HOST_BITS_MASK_BINARY="00000000000000000000000000000000"
    HOST_BITS_MASK_BINARY=${HOST_BITS_MASK_BINARY::-${HOST_BITS}} # remove last bits, as many as HOST_BITS are
    BROADCAST_ADDRESS_BINARY=$(echo ${IP_BINARY//.}) # remove dots
    BROADCAST_ADDRESS_BINARY=${BROADCAST_ADDRESS_BINARY::-${HOST_BITS}} # remove last bits, as many as HOST_BITS are
    
    BITS=$(( 32 - HOST_BITS )) # append bits to trimmed binary
    until [[ "${BITS}" -eq 32 ]]; do
      BROADCAST_ADDRESS_BINARY+="1" # append a bit every loop
      HOST_BITS_MASK_BINARY+="1" # append a bit every loop
      let BITS+=1
    done
    
    BROADCAST_ADDRESS_BINARY=$(echo "${BROADCAST_ADDRESS_BINARY}" | sed --expression="s/\(.\{8\}\)/\1./g" --expression="s/\(.*\)./\1 /") # put dot every 8th character and remove last occurence of dot
    HOST_BITS_MASK_BINARY=$(echo "${HOST_BITS_MASK_BINARY}" | sed --expression="s/\(.\{8\}\)/\1./g" --expression="s/\(.*\)./\1 /") # put dot every 8th character and remove last occurence of dot

    PART_A=$(echo "${BROADCAST_ADDRESS_BINARY}" | cut --delimiter='.' --fields=1); PART_B=$(echo "${BROADCAST_ADDRESS_BINARY}" | cut --delimiter='.' --fields=2)
    PART_C=$(echo "${BROADCAST_ADDRESS_BINARY}" | cut --delimiter='.' --fields=3); PART_D=$(echo "${BROADCAST_ADDRESS_BINARY}" | cut --delimiter='.' --fields=4)
    BROADCAST_ADDRESS="$(bin_to_dec ${PART_A}).$(bin_to_dec ${PART_B}).$(bin_to_dec ${PART_C}).$(bin_to_dec ${PART_D})"
    
    printf "${COLORS[0]}%-12s${COLORS[5]}%-22s${COLORS[1]}%s${COLORS[0]}\n" "Address:" "${IP}" "${IP_BINARY}"
    printf "${COLORS[0]}%-12s${COLORS[5]}%-22s${COLORS[1]}%s${COLORS[0]}\n" "Netmask:" "${NETMASK} = ${CIDR}" "${NETMASK_BINARY}"
    printf "${COLORS[0]}%-12s${COLORS[5]}%-22s${COLORS[1]}%s${COLORS[0]}\n" "Wildcard:" "${WILDCARD}" "${WILDCARD_BINARY}"
    printf "=>\n"
    printf "${COLORS[0]}%-12s${COLORS[5]}%-22s${COLORS[1]}%s${COLORS[0]}\n" "Network:" "${NETWORK_ADDRESS}/${CIDR}" "${NETWORK_ADDRESS_BINARY}"
    printf "${COLORS[0]}%-12s${COLORS[5]}%-22s${COLORS[1]}%s${COLORS[0]}\n" "Broadcast:" "${BROADCAST_ADDRESS}" "${BROADCAST_ADDRESS_BINARY}"
  fi

  return 0
}

# Prints the driver used of active interface.
function show_driver() {
  
  local DRIVER_OF
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    if [[ -f "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent" ]]; then
      DRIVER_OF=$(awk --field-separator="=" 'tolower($0) ~ /driver/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent")
    else
      DRIVER_OF=$(awk --field-separator="=" 'tolower($0) ~ /driver/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/device/uevent")
    fi
    echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" 
  done

  return 0
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
    INPUT=$(echo "${1}" | sed --expression='s/^http\(\|s\):\/\///g' --expression='s/^`//' --expression='s/`//' --expression='s/`$//' | cut --fields=1 --delimiter="/")
  
    echo -ne "Pinging ${COLORS[2]}$1${COLORS[0]} ..."
    for i in {1..25}; do
      ping -c 1 -w "${LONG_TIMEOUT}" "${INPUT}" 2> /dev/null | awk --field-separator='[()]' '/PING/{print $2}' >> "${TEMP_FILE}" &
    done
    handle_jobs
  
    clear_line
    awk '{print $0}' "${TEMP_FILE}" | sort --version-sort --unique
  fi

  return 0
}

# Prints all valid IPv4, IPv6 and MAC addresses extracted from file.
function show_ips_from_file() {
    
  if [[ -z "${1}" ]]; then error_exit "No file was specified. ${DIALOG_ABORTING}"; fi
  for FILE in "${@}"; do
    if [[ ! -f "${FILE}" ]]; then error_exit "${COLORS[3]}${FILE}${COLORS[0]} does not exist. ${DIALOG_ABORTING}"; fi
  done
    
  local TEMP_FILE_IPV4
  local TEMP_FILE_IPV6
  local TEMP_FILE_MAC
  local IS_TEMP_FILE_IPV4_EMPTY
  local IS_TEMP_FILE_IPV6_EMPTY
  local IS_TEMP_FILE_MAC_EMPTY

  TEMP_FILE_IPV4=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
  TEMP_FILE_IPV6=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
  TEMP_FILE_MAC=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)

  init_regexes

  for FILE in "${@}"; do
    grep --extended-regexp --only-matching "${REGEX_IPV4}" "${FILE}" 2>/dev/null | sort --version-sort --unique >> "${TEMP_FILE_IPV4}"
    grep --extended-regexp --only-matching "${REGEX_IPV6}" "${FILE}" 2>/dev/null | sort --version-sort --unique >> "${TEMP_FILE_IPV6}"
    grep --extended-regexp --only-matching "${REGEX_MAC}"  "${FILE}" 2>/dev/null | sort --version-sort --unique >> "${TEMP_FILE_MAC}"
  done

  if [[ -s "${TEMP_FILE_IPV4}" ]]; then IS_TEMP_FILE_IPV4_EMPTY=0; else IS_TEMP_FILE_IPV4_EMPTY=1; fi
  if [[ -s "${TEMP_FILE_IPV6}" ]]; then IS_TEMP_FILE_IPV6_EMPTY=0; else IS_TEMP_FILE_IPV6_EMPTY=1; fi
  if [[ -s "${TEMP_FILE_MAC}" ]]; then IS_TEMP_FILE_MAC_EMPTY=0; else IS_TEMP_FILE_MAC_EMPTY=1; fi

  case "${IS_TEMP_FILE_IPV4_EMPTY}:${IS_TEMP_FILE_IPV6_EMPTY}:${IS_TEMP_FILE_MAC_EMPTY}" in
    0:0:0) # IPv4, IPv6 and MAC addresses
      paste "${TEMP_FILE_IPV4}" "${TEMP_FILE_IPV6}" "${TEMP_FILE_MAC}" | awk --field-separator='\t' '{printf("%-16s%-40s%s\n", $1, $2, toupper($3))}'
    ;;
    0:0:1) # Only IPv4 and IPv6 addresses
      paste "${TEMP_FILE_IPV4}" "${TEMP_FILE_IPV6}" | awk --field-separator='\t' '{printf("%-16s%s\n", $1, $2)}' 
    ;;
    0:1:0) # Only IPv4 and MAC addresses
      paste "${TEMP_FILE_IPV4}" "${TEMP_FILE_MAC}" | awk --field-separator='\t' '{printf("%-16s%s\n", $1, toupper($2))}'
    ;;
    0:1:1) # Only IPv4 addresses
      paste "${TEMP_FILE_IPV4}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
    ;;
    1:0:0) # Only IPv6 and MAC addresses
      paste "${TEMP_FILE_IPV6}" "${TEMP_FILE_MAC}" | awk --field-separator='\t' '{printf("%-40s%s\n", $1, toupper($2))}'
    ;;
    1:0:1) # Only IPv6 addresses
      paste "${TEMP_FILE_IPV6}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
    ;;
    1:1:0) # Only MAC addresses
      paste "${TEMP_FILE_MAC}" | awk --field-separator='\t' '{printf("%s\n", toupper($1))}'
    ;;
    1:1:1) # None
      error_exit "${DIALOG_NO_VALID_ADDRESSES}"
    ;;
  esac

  return 0
}

# Prints active network interfaces and their gateway.
function show_gateway() {
  
  local GATEWAY
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))

  for i in "${!INTERFACES_ARRAY[@]}"; do
    GATEWAY=$(ip route | awk "/${INTERFACES_ARRAY[i]}/ && tolower(\$0) ~ /default/ {print \$3}")
    echo "${INTERFACES_ARRAY[i]}" "${GATEWAY}"
  done

  return 0
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

  return 0
}

# Prints active network interfaces.
function show_interfaces() {

  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))

  echo "${INTERFACES_ARRAY[@]}"

  return 0
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

  return 0
}

# Prints hops to a destination. $1=--ipv4|--ipv6, $2=network destination.
function show_next_hops() {
  
  local FILTERED_INPUT
  local PROTOCOL
  local TRACEPATH_CMD
  local TRACEROUTE_CMD
  local MTR_CMD
  local TEMP_FILE

  TEMP_FILE=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)

  hash tracepath &>/dev/null && TRACEPATH_CMD=1 || TRACEPATH_CMD=0
  hash traceroute &>/dev/null && TRACEROUTE_CMD=1 || TRACEROUTE_CMD=0
  hash mtr &>/dev/null && MTR_CMD=1 || MTR_CMD=0

  FILTERED_INPUT=$(echo "${2}" | sed 's/^http\(\|s\):\/\///g' | cut --fields=1 --delimiter="/")

  check_for_missing_args "${DIALOG_NO_ARGUMENTS}" "${FILTERED_INPUT}"
  
  case "${1}" in
    "--ipv4") PROTOCOL=4; ;;
    "--ipv6") check_ipv6; PROTOCOL=6; ;;
  esac

  print_check "${FILTERED_INPUT}"

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
          mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}"
        ;;
        6)
          mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}"
        ;;
      esac
    ;;
    # If it is installed 'traceroute' only
    0:1:0)
      case "${PROTOCOL}" in
        4)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" | tail --lines=+2
        ;;
        6)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching  "${REGEX_IPV6}" | tail --lines=+2
        ;;
      esac
    ;;
    # If it is installed 'traceroute' and 'mtr' only
    0:1:1)
      case "${PROTOCOL}" in
        4)
           mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}"
        ;;
        6)
           mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}"
        ;;
      esac
    ;;
    # If it is installed 'tracepath' only
    1:0:0)
      # tracepath6 workaround: Many linux distributions do not have tracepath6 (it is included in manpages tho :/)
      hash tracepath6 &>/dev/null && PROTOCOL=6
      if [[ "${PROTOCOL}" -eq 4 ]]; then echo -e "${DIALOG_NO_TRACEPATH6}"; fi

      case "${PROTOCOL}" in
        4)
          timeout "${SHORT_TIMEOUT}" tracepath"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | awk '{print $2}' | grep --extended-regexp --only-matching "${REGEX_IPV4}"
        ;;
        6)
          timeout "${SHORT_TIMEOUT}" tracepath"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | awk '{print $2}' | grep --extended-regexp --only-matching "${REGEX_IPV6}"
        ;;
      esac
    ;;
    # If it is installed 'tracepath' and 'mtr' only
    1:0:1)
      case "${PROTOCOL}" in
        4)
          mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}"
        ;;
        6)
          mtr -"${PROTOCOL}" --report-cycles 2 --no-dns --report "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}"
        ;;
      esac
    ;;
    # If it is installed 'tracepath' and 'traceroute' only
    1:1:0)
      case "${PROTOCOL}" in
        4)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" | tail --lines=+2
        ;;
        6)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}" | tail --lines=+2
        ;;
      esac
    ;;
    # If it is installed 'tracepath', 'traceroute' and 'mtr'
    1:1:1)
      case "${PROTOCOL}" in
        4)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV4}" | tail --lines=+2
        ;;
        6)
          timeout "${SHORT_TIMEOUT}" traceroute -"${PROTOCOL}" -n "${FILTERED_INPUT}" 2> /dev/null | grep --extended-regexp --only-matching "${REGEX_IPV6}" | tail --lines=+2
        ;;
      esac
    ;;
  esac >> "${TEMP_FILE}"
  
  clear_line
  awk '{print $0}' "${TEMP_FILE}" | uniq

  return 0
}

# Prints a list of private and reserved IPs. $1 "normal" or "cidr".
function show_bogon_ips() {

  declare -r IPV4_BOGON_ARRAY=(
    "0.0.0.0" "10.0.0.0" "100.64.0.0" "127.0.0.0" "127.0.53.53" "169.254.0.0"
    "172.16.0.0" "192.0.0.0" "192.0.2.0" "192.168.0.0" "198.18.0.0"
    "198.51.100.0" "203.0.113.0" "224.0.0.0" "240.0.0.0" "255.255.255.255"
  );
  declare -r IPV6_BOGON_ARRAY=(
    "::" "::1" "::ffff:0:0" "::" "100::" "2001:10::" "2001:db8::" "fc00::"
    "fe80::" "fec0::" "ff00::"
  );
  declare -r IPV4_CIDR_BOGON_ARRAY=(
    "0.0.0.0/8" "10.0.0.0/8" "100.64.0.0/10" "127.0.0.0/8" "127.0.53.53/8"
    "169.254.0.0/16" "172.16.0.0/12" "192.0.0.0/24" "192.0.2.0/24" "192.168.0.0/16"
    "198.18.0.0/15" "198.51.100.0/24" "203.0.113.0/24" "224.0.0.0/4" "240.0.0.0/4"
    "255.255.255.255/32"
  );
  declare -r IPV6_CIDR_BOGON_ARRAY=(
    "::/128" "::1/128" "::ffff:0:0/96" "::/96" "100::/64" "2001:10::/28"
    "2001:db8::/32" "fc00::/7" "fe80::/10" "fec0::/10" "ff00::/8"
  );
  declare -r IPV4_DIALOG_ARRAY=(
    "'This' network" "Private-use networks" "Carrier-grade NAT" "Loopback"
    "Name collision occurrence" "Link local" "Private-use networks"
    "IETF protocol assignments" "TEST-NET-1" "Private-use networks"
    "Network interconnect device benchmark testing" "TEST-NET-2" "TEST-NET-3"
    "Multicast" "Reserved for future use" "Limited broadcast"
  );
  declare -r IPV6_DIALOG_ARRAY=(
    "Node-scope unicast unspecified address" "Node-scope unicast loopback address"
    "IPv4-mapped addresses" "IPv4-compatible addresses"
    "Remotely triggered black hole addresses"
    "Overlay routable cryptographic hash identifiers (ORCHID)"
    "Documentation prefix" "Unique local addresses (ULA)" "Link-local unicast"
    "Site-local unicast (deprecated)"
    "Multicast (Note: ff0e:/16 is global scope and may appear on the global internet)"
  );

  case "${1}" in
    "normal")
      for IP in "${!IPV4_DIALOG_ARRAY[@]}"; do
        printf "%-16s%s\n" "${IPV4_BOGON_ARRAY[IP]}" "${IPV4_DIALOG_ARRAY[IP]}"
      done
      
      for IP in "${!IPV6_DIALOG_ARRAY[@]}"; do
        printf "%-16s%s\n" "${IPV6_BOGON_ARRAY[IP]}" "${IPV6_DIALOG_ARRAY[IP]}"
      done
    ;;
    "cidr")
      for IP in "${!IPV4_DIALOG_ARRAY[@]}"; do
        printf "%-19s%s\n" "${IPV4_CIDR_BOGON_ARRAY[IP]}" "${IPV4_DIALOG_ARRAY[IP]}"
      done
      
      for IP in "${!IPV6_DIALOG_ARRAY[@]}"; do
        printf "%-19s%s\n" "${IPV6_CIDR_BOGON_ARRAY[IP]}" "${IPV6_DIALOG_ARRAY[IP]}"
      done
    ;;
  esac

  return 0
}

# Prints active network interfaces with their MAC address.
function show_mac() {
  
  local MAC_OF
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    MAC_OF=$(awk '{print toupper($0)}' "/sys/class/net/${INTERFACES_ARRAY[i]}/address" 2> /dev/null)
    echo "${INTERFACES_ARRAY[i]}" "${MAC_OF}"
  done

  return 0
}

# Shows neighbor table.
function show_neighbor_cache() {
  
  local TEMP_FILE
  
  TEMP_FILE=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)

  ip neigh | awk 'tolower($0) ~ /permanent|noarp|stale|reachable|incomplete|delay|probe/{printf ("%-16s%-20s%s\n", $1, toupper($5), $6)}' >> "${TEMP_FILE}"
  
  awk '{print $0}' "${TEMP_FILE}" | sort --version-sort

  return 0
}

# Extracts valid IPv4, IPv6 and MAC addresses from URLs.
function show_ips_from_online_document() {

  check_for_missing_args "No URL was specified. ${DIALOG_ABORTING}" "${1}"

  local HTTP_CODE   
  local TEMP_FILE_IPV4
  local TEMP_FILE_IPV6
  local TEMP_FILE_MAC
  local TEMP_FILE_HTML
  local IS_TEMP_FILE_IPV4_EMPTY
  local IS_TEMP_FILE_IPV6_EMPTY
  local IS_TEMP_FILE_MAC_EMPTY

  TEMP_FILE_IPV4=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
  TEMP_FILE_IPV6=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
  TEMP_FILE_MAC=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)
  TEMP_FILE_HTML=$(mktemp "${TEMP}"/"${SCRIPT_NAME}".XXXXXXXXXX)

  init_regexes

  for DOCUMENT in "${@}"; do
    print_check "${DOCUMENT}"
    HTTP_CODE=$(wget --spider --tries 1 --timeout="${TIMEOUT}" --server-response "${DOCUMENT}" 2>&1 | awk '/HTTP\//{print $2}' | tail --lines=1)
    
    clear_line
    
    if [[ ! "${HTTP_CODE}" -eq 200 ]]; then
      error_exit "${COLORS[3]}${DOCUMENT}${COLORS[0]} is unreachable. Input was invalid or server is down or has connection issues. ${DIALOG_ABORTING}"
    fi
      
    echo -ne "Downloading ${COLORS[2]}$1${COLORS[0]} ..."
    wget "${DOCUMENT}" --quiet --output-document="${TEMP_FILE_HTML}"
    clear_line

    grep --extended-regexp --only-matching "${REGEX_IPV4}" "${TEMP_FILE_HTML}" | sort --version-sort --unique >> "${TEMP_FILE_IPV4}"
    grep --extended-regexp --only-matching "${REGEX_IPV6}" "${TEMP_FILE_HTML}" | sort --version-sort --unique >> "${TEMP_FILE_IPV6}"
    grep --extended-regexp --only-matching "${REGEX_MAC}" "${TEMP_FILE_HTML}" | sort --version-sort --unique >> "${TEMP_FILE_MAC}"
  done

  if [[ -s "${TEMP_FILE_IPV4}" ]]; then IS_TEMP_FILE_IPV4_EMPTY=0; else IS_TEMP_FILE_IPV4_EMPTY=1; fi
  if [[ -s "${TEMP_FILE_IPV6}" ]]; then IS_TEMP_FILE_IPV6_EMPTY=0; else IS_TEMP_FILE_IPV6_EMPTY=1; fi
  if [[ -s "${TEMP_FILE_MAC}" ]]; then IS_TEMP_FILE_MAC_EMPTY=0; else IS_TEMP_FILE_MAC_EMPTY=1; fi

  case "${IS_TEMP_FILE_IPV4_EMPTY}:${IS_TEMP_FILE_IPV6_EMPTY}:${IS_TEMP_FILE_MAC_EMPTY}" in
    0:0:0) # IPv4, IPv6 and MAC addresses
      paste "${TEMP_FILE_IPV4}" "${TEMP_FILE_IPV6}" "${TEMP_FILE_MAC}" | awk --field-separator='\t' '{printf("%-16s%-40s%s\n", $1, $2, toupper($3))}'
    ;;
    0:0:1) # Only IPv4 and IPv6 addresses
      paste "${TEMP_FILE_IPV4}" "${TEMP_FILE_IPV6}" | awk --field-separator='\t' '{printf("%-16s%s\n", $1, $2)}' 
    ;;
    0:1:0) # Only IPv4 and MAC addresses
      paste "${TEMP_FILE_IPV4}" "${TEMP_FILE_MAC}" | awk --field-separator='\t' '{printf("%-16s%s\n", $1, toupper($2))}'
    ;;
    0:1:1) # Only IPv4 addresses
      paste "${TEMP_FILE_IPV4}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
    ;;
    1:0:0) # Only IPv6 and MAC addresses
      paste "${TEMP_FILE_IPV6}" "${TEMP_FILE_MAC}" | awk --field-separator='\t' '{printf("%-40s%s\n", $1, toupper($2))}'
    ;;
    1:0:1) # Only IPv6 addresses
      paste "${TEMP_FILE_IPV6}" | awk --field-separator='\t' '{printf("%s\n", $1)}'
    ;;
    1:1:0) # Only MAC addresses
      paste "${TEMP_FILE_MAC}" | awk --field-separator='\t' '{printf("%s\n", toupper($1))}'
    ;;
    1:1:1) # None
      error_exit "${DIALOG_NO_VALID_ADDRESSES}"
    ;;
  esac

  return 0
}

# Prints script's version and author's info.
function show_version() {

  echo
  echo -e "                        ${COLORS[3]}//"
  echo -e "                        ${COLORS[3]}oo"
  echo -e "                        ss             "
  echo -e "         ${COLORS[3]}::\`      \`\`----//----.\`    \`/s:"
  echo -e "         ${COLORS[3]}.+o:.\`\`---.\`  \`.\`\`   .----/s/\`"
  echo -e "           ${COLORS[3]}\`+y/.  ..-...ss....-\`  -+/"
  echo -e "            ${COLORS[3]}:-\` ./-\`    o+    \`o+. \`.:"
  echo -e "           ${COLORS[3]}:\` .-:oo-\`  \`ys\` \`-o+-.-. \`/"
  echo -e "          ${COLORS[3]}:.  :\`  .+so-.os./ss-   \`:  \`:"
  echo -e "     ${COLORS[3]}   \`\`/ \`.:\`  \`.:o-.-:.-+.\`\`  \`--\` /\`\`       ${COLORS[0]}Author .: ${COLORS[4]}${AUTHOR} - ${COLORS[1]}xtonousou"
  echo -e "   ${COLORS[3]}\`++/++s/ \`:o+/++ss-.+yy+.:ss++/+o/\` :s++/++\`  ${COLORS[0]}Mail ...: ${COLORS[4]}${GMAIL}"
  echo -e "    ${COLORS[3]}\`\` \`\`\`/  .:\` \`\`\`./../:.-+:.\`\` \`--  /.\`\` \`\`   ${COLORS[0]}Github .: ${COLORS[4]}${GITHUB}"
  echo -e "          ${COLORS[3]}:.\`\`:\`   .ss/.oo.-os/\`   :\`\`\`/         ${COLORS[0]}Version : ${COLORS[4]}${VERSION}"
  echo -e "           ${COLORS[3]}/\`  -.-/o:\` \`ys\`  .:o+:-\` \`/\`"
  echo -e "            ${COLORS[3]}:.  -+o\`    o+     -+-  .:\`"
  echo -e "             ${COLORS[3]}/+.\` \`.....ss...-.\` ../y+\`"
  echo -e "           ${COLORS[3]}\`/s+---.\` .\`\`\`\`\`.\` \`.--\`\`./o/."
  echo -e "          ${COLORS[3]}::/\`    \`.----//----.\`      \`\\::"
  echo -e "          ${COLORS[3]}             \`ss\`"
  echo -e "                        ${COLORS[3]}oo"
  echo -e "                        ${COLORS[3]}//${COLORS[0]}"
  echo

  return 0
}

# Prints active network interfaces with their IPv4 address and CIDR suffix.
function show_ipv4_cidr() {

  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))
  declare IPV4_CIDR_ARRAY=($(ip address show | awk '$1 ~ /inet$/{print $2}' | tail --lines=+2))
  
  for i in "${!IPV4_CIDR_ARRAY[@]}"; do
    echo "${INTERFACES_ARRAY[i]}" "${IPV4_CIDR_ARRAY[i]}"
  done

  return 0
}

# Prints active network interfaces with their IPv6 address and CIDR suffix.
function show_ipv6_cidr() {

  check_ipv6
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))
  declare IPV6_CIDR_ARRAY=($(ip address show | awk '$1 ~ /inet6$/{print toupper($2)}' | tail --lines=+2))

  for i in "${!IPV6_CIDR_ARRAY[@]}"; do
    echo "${INTERFACES_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
  done

  return 0
}

# Prints all info and CIDR suffix.
function show_all_cidr() {
  
  local MAC_OF
  local DRIVER_OF
  local GATEWAY
  local CIDR
  
  declare INTERFACES_ARRAY=($(ip route | awk 'tolower($0) ~ /default/ {print $5}'))
  declare IPV4_CIDR_ARRAY=($(ip address show | awk '$1 ~ /inet$/{print $2}' | tail --lines=+2))
  declare IPV6_CIDR_ARRAY=($(ip address show | awk '$1 ~ /inet6$/{print toupper($2)}' | tail --lines=+2))
  
  for i in "${!INTERFACES_ARRAY[@]}"; do
    if [[ -f "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent" ]]; then
      DRIVER_OF=$(awk --field-separator="=" 'tolower($0) ~ /driver/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/phy80211/device/uevent")
    else
      DRIVER_OF=$(awk --field-separator="=" 'tolower($0) ~ /driver/{print $2}' "/sys/class/net/${INTERFACES_ARRAY[i]}/device/uevent")
    fi
    MAC_OF=$(awk '{print toupper($0)}' "/sys/class/net/${INTERFACES_ARRAY[i]}/address" 2> /dev/null)
    GATEWAY=$(ip route | awk "/${INTERFACES_ARRAY[i]}/ && tolower(\$0) ~ /default/ {print \$3}")
    CIDR=$(echo -n "${IPV4_CIDR_ARRAY[i]}" | sed 's/^.*\//\//')
    if grep --ignore-case "ipv6" "/proc/modules" &>/dev/null; then
      echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" "${MAC_OF}" "${GATEWAY}${CIDR}" "${IPV4_CIDR_ARRAY[i]}" "${IPV6_CIDR_ARRAY[i]}"
    else
      echo "${INTERFACES_ARRAY[i]}" "${DRIVER_OF}" "${MAC_OF}" "${GATEWAY}${CIDR}" "${IPV4_CIDR_ARRAY[i]}"
    fi
  done

  return 0
}

# Prints help message.
function show_usage() {
  
  echo    "  usage: ${SCRIPT_NAME} [OPTION] <ARGUMENT/S>"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-4 ${COLORS[0]}, ${COLORS[0]}--ipv4 ${COLORS[0]}            shows active interfaces with their IPv4 address"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-6 ${COLORS[0]}, ${COLORS[0]}--ipv6 ${COLORS[0]}            shows active interfaces with their IPv6 address"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-a ${COLORS[0]}, ${COLORS[0]}--all ${COLORS[0]}             shows all network info"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-a ${COLORS[0]}, ${COLORS[0]}--all ${COLORS[0]}<>           shows network info of target IP address"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-d ${COLORS[0]}, ${COLORS[0]}--driver ${COLORS[0]}          shows each active interface's driver"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-e ${COLORS[0]}, ${COLORS[0]}--external ${COLORS[0]}        shows your external IP address"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-e ${COLORS[0]}, ${COLORS[0]}--external ${COLORS[0]}<>      shows external IP addresses"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-f ${COLORS[0]}, ${COLORS[0]}--find ${COLORS[0]}<>          shows valid IP and MAC addresses found on a file"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-g ${COLORS[0]}, ${COLORS[0]}--gateway ${COLORS[0]}         shows gateway of online interfaces"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-h ${COLORS[0]}, ${COLORS[0]}--help${COLORS[0]}             shows this help message"
  echo -e " ${SCRIPT_NAME} ${COLORS[1]}-H ${COLORS[0]}, ${COLORS[1]}--hosts ${COLORS[0]}           shows active hosts on network"
  echo -e " ${SCRIPT_NAME} ${COLORS[1]}-HM${COLORS[0]}, ${COLORS[1]}--hosts-mac ${COLORS[0]}       shows active hosts on network with their MAC address"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-i ${COLORS[0]}, ${COLORS[0]}--interfaces ${COLORS[0]}      shows active interfaces"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-l ${COLORS[0]}, ${COLORS[0]}--list ${COLORS[0]}            shows a list of private and reserved IP addresses"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-m ${COLORS[0]}, ${COLORS[0]}--mac ${COLORS[0]}             shows active interfaces with their MAC address"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-n ${COLORS[0]}, ${COLORS[0]}--neighbor ${COLORS[0]}        shows neighbor cache"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-P ${COLORS[0]}, ${COLORS[0]}--port ${COLORS[0]}            shows a list of common ports"
  echo -e " ${SCRIPT_NAME} ${COLORS[1]}-P ${COLORS[0]}, ${COLORS[1]}--port ${COLORS[0]}<>          shows connections to a port per IP"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-r ${COLORS[0]}, ${COLORS[0]}--route-ipv4 ${COLORS[0]}<>    shows the path to a network host using IPv4"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-r6${COLORS[0]}, ${COLORS[0]}--route-ipv6 ${COLORS[0]}<>    shows the path to a network host using IPv6"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-u ${COLORS[0]}, ${COLORS[0]}--url ${COLORS[0]}<>           shows valid IP and MAC addresses found on a website"
  echo -e " ${SCRIPT_NAME} ${COLORS[0]}-v ${COLORS[0]}, ${COLORS[0]}--version ${COLORS[0]}         shows the version of script"
  echo -e " ${SCRIPT_NAME} ${COLORS[2]}--cidr-4${COLORS[0]}, ${COLORS[2]}--cidr-ipv4 ${COLORS[0]}  shows active interfaces with their IPv4 address and CIDR"
  echo -e " ${SCRIPT_NAME} ${COLORS[2]}--cidr-6${COLORS[0]}, ${COLORS[2]}--cidr-ipv6 ${COLORS[0]}  shows active interfaces with their IPv6 address and CIDR"
  echo -e " ${SCRIPT_NAME} ${COLORS[2]}--cidr-a${COLORS[0]}, ${COLORS[2]}--cidr-all ${COLORS[0]}   shows all basic info with CIDR"
  echo -e " ${SCRIPT_NAME} ${COLORS[2]}--cidr-a${COLORS[0]}, ${COLORS[2]}--cidr-all ${COLORS[0]}<> shows network info of target IP address"
  echo -e " ${SCRIPT_NAME} ${COLORS[2]}--cidr-l${COLORS[0]}, ${COLORS[2]}--cidr-list ${COLORS[0]}  shows a list of private and reserved IP addresses with CIDR"
  echo -e "  options in ${COLORS[2]}GREEN${COLORS[0]} include ${COLORS[2]}CIDR${COLORS[0]} notation"
  echo -e "  options in ${COLORS[1]}RED${COLORS[0]}   require ${COLORS[1]}ROOT${COLORS[0]} privileges"

  return 0
}

# Starts ship.
function sail() {
  
  if [[ -z "${1}" ]]; then error_exit "${DIALOG_ERROR}"; fi

  check_bash_version
  
  while :; do
    case "${1}" in
      "-4"|"--ipv4") check_connectivity "--local"; show_ipv4; break ;;
      "-6"|"--ipv6") check_connectivity "--local"; show_ipv6; break ;;
      "-a"|"--all") check_connectivity "--local"; show_all "${@:2}"; break ;;
      "-d"|"--driver") check_connectivity "--local"; show_driver; break ;;
      "-e"|"--external") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_ip_from "${2}"; shift 2; break ;;
      "-f"|"--find") trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_ips_from_file "${@:2}"; break ;;
      "-g"|"--gateway") check_connectivity "--local"; show_gateway; break ;;
      "-h"|"--help") show_usage; break ;;
      "-H"|"--hosts") check_connectivity "--local"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_live_hosts --normal; break ;;
      "-HM"|"--hosts-mac") check_connectivity "--local"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_live_hosts --mac; break ;;
      "-i"|"--interfaces") check_connectivity "--local"; show_interfaces; break ;;
      "-P"|"--port") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_port_connections "${2}"; shift 2; break ;;
      "-r"|"--route-ipv4") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_next_hops --ipv4 "${2}"; shift 2; break ;;
      "-r6"|"--route-ipv6") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_next_hops --ipv6 "${2}"; shift 2; break ;;
      "-l"|"--list") show_bogon_ips "normal"; break ;;
      "-m"|"--mac") check_connectivity "--local"; show_mac; break ;;
      "-n"|"--neighbor") check_connectivity "--local"; show_neighbor_cache; break ;;
      "-u"|"--url") check_connectivity "--internet"; trap trap_handler INT &>/dev/null; trap trap_handler SIGTSTP &>/dev/null; show_ips_from_online_document "${@:2}"; break ;;
      "-v"|"--version") show_version; break ;;
      "--cidr-4"|"--cidr-ipv4") check_connectivity "--local"; show_ipv4_cidr; break ;;
      "--cidr-6"|"--cidr-ipv6") check_connectivity "--local"; show_ipv6_cidr; break ;;
      "--cidr-a"|"--cidr-all") check_connectivity "--local"; show_all_cidr "${@:2}"; break ;;
      "--cidr-l"|"--cidr-list") show_bogon_ips "cidr"; break ;;
      *) error_exit "${DIALOG_ERROR}" "${1}"; break ;;
    esac
  done

  trap mr_proper 0 1
  exit 0
}

sail "${@}"
