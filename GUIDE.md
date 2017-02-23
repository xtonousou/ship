# Guide

<details>
	<summary id="toc"><strong>Table Of Contents</strong></summary>
* [Usage]
 * [General Usage]
 * [IP Calculation Usage]
* [Examples]
 * [General Examples]
 * [IP Calculation Examples]
</details>

## Usage
#### General Usage

```bash
 usage: ship [OPTION] <ARGUMENT/S>
  ship -4 , --ipv4           shows active interfaces with their IPv4 address
  ship -6 , --ipv6           shows active interfaces with their IPv6 address
  ship -a , --all            shows all information
  ship -c , --calculate <>   shows calculated IP information
  ship -d , --driver         shows each active interface's driver
  ship -e , --external       shows your external IP address
  ship -e , --external <>    shows external IP addresses
  ship -f , --find <>        shows valid IP and MAC addresses found on file/s
  ship -g , --gateway        shows gateway of online interfaces
  ship -h , --help           shows this help message
  ship -H , --hosts          shows active hosts on network
  ship -HM, --hosts-mac      shows active hosts on network with their MAC address
  ship -i , --interfaces     shows active interfaces
  ship -l , --list           shows a list of private and reserved IP addresses
  ship -m , --mac            shows active interfaces with their MAC address
  ship -n , --neighbor       shows neighbor cache
  ship -P , --port           shows a list of common ports
  ship -P , --port <>        shows connections to a port per IP
  ship -r , --route-ipv4 <>  shows the path to a network host using IPv4
  ship -r6, --route-ipv6 <>  shows the path to a network host using IPv6
  ship -u , --url <>         shows valid IP and MAC addresses found on website/s
  ship -v , --version        shows the version of script
  ship --cidr-4, --cidr-ipv4 shows active interfaces with their IPv4 address and CIDR
  ship --cidr-6, --cidr-ipv6 shows active interfaces with their IPv6 address and CIDR
  ship --cidr-a, --cidr-all  shows all information with CIDR
  ship --cidr-l, --cidr-list shows a list of private and reserved IP addresses with CIDR
 options in green force include CIDR notation
 options in red require ROOT privileges
```

#### IP Calculation Usage

```bash
 usage:
  ship -c, --calculate <OPTIONS> 192.168.0.1
  ship -c, --calculate <OPTIONS> 192.168.0.1/24
  ship -c, --calculate <OPTIONS> 192.168.0.1 255.255.255.0
 options:
  -b, --nobinary suppress the bitwise output 
  -h, --html     display results as HTML
  -s, --split    split into networks of size n1, n2, n3
  -r, --range    deaggregate address range
```

## Examples
#### General Examples
#### IP Calculation Examples

<!-- Anchors -->
[Usage]: #usage
[General Usage]: #general-usage
[IP Calculation Usage]: #ip-calculation-usage
[Examples]: #examples
[General Examples]: #general-examples
[IP Calculation Examples]: #ip-calculation-examples
