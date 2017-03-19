# Guide

## Table of Contents

* [Usage]
  * [General Usage]
  * [IP Calculation Usage]
* [Examples]
  * [General Examples]
  * [IP Calculation Examples]

## Usage
#### General Usage

```
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

```
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
* `ship -e , --external https://github.com/`
[![asciicast](https://asciinema.org/a/104424.png)](https://asciinema.org/a/104424)
* `ship -f , --find ~/ipv4 ~/ipv6 ~/mac`
[![asciicast](https://asciinema.org/a/104427.png)](https://asciinema.org/a/104427)
* `ship -P , --port 80`
[![asciicast](https://asciinema.org/a/104428.png)](https://asciinema.org/a/104428)
* `ship -u , --url https://github.com/ https://en.wikipedia.org/wiki/IPv4 http://askubuntu.com/questions/406792/list-all-mac-addresses-and-their-associated-ip-addresses-in-my-local-network-la https://www.space.net/~gert/RIPE/ipv6-filters.html`
[![asciicast](https://asciinema.org/a/104429.png)](https://asciinema.org/a/104429)

#### IP Calculation Examples
* `ship -c , --calculate 192.168.1.1`
[![asciicast](https://asciinema.org/a/104430.png)](https://asciinema.org/a/104430)
* `ship -c , --calculate 192.168.6.56/20`
[![asciicast](https://asciinema.org/a/104431.png)](https://asciinema.org/a/104431)
* `ship -c , --calculate 10.0.0.56 255.240.0.0`
[![asciicast](https://asciinema.org/a/104432.png)](https://asciinema.org/a/104432)
* `ship -c , --calculate -b , --nobinary 127.0.0.1`
[![asciicast](https://asciinema.org/a/104433.png)](https://asciinema.org/a/104433)
* `ship -c , --calculate -h , --html 192.168.1.2/24`
[![asciicast](https://asciinema.org/a/104436.png)](https://asciinema.org/a/104436)
![alt text](https://raw.githubusercontent.com/xtonousou/shIP/dev/imgs/example1.png "Example One")
* `ship -c , --calculate -b , --nobinary -h , --html 216.58.205.35`
[![asciicast](https://asciinema.org/a/104437.png)](https://asciinema.org/a/104437)
![alt text](https://raw.githubusercontent.com/xtonousou/shIP/dev/imgs/example2.png "Example Two")

##### More coming soon ... :anchor:

<!-- Anchors -->
[Usage]: #usage
[General Usage]: #general-usage
[IP Calculation Usage]: #ip-calculation-usage
[Examples]: #examples
[General Examples]: #general-examples
[IP Calculation Examples]: #ip-calculation-examples
