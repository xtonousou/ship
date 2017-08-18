# Guide :mag:

## Table of Contents

:ship: | Argument                  | Description                                                 | Example
------:|:--------------------------|:------------------------------------------------------------|:--------------------:
 ship  | **-4 , --ipv4**           | shows active interfaces with their IPv4 address             | [ipv4]
 ship  | **-6 , --ipv6**           | shows active interfaces with their IPv6 address             | [ipv6]
 ship  | **-a , --all**            | shows all information                                       | [all]
 ship  | **-A , --all-interfaces** | shows all available network interfaces                      | [all-interfaces]
 ship  | **-c , --calculate <>**   | shows calculated IP information                             | [calculate-with-arg]
 ship  | **-d , --driver**         | shows each active interface's driver                        | [driver]
 ship  | **-e , --external**       | shows your external IP address                              | [external]
 ship  | **-e , --external <>**    | shows external IP addresses                                 | [external-with-arg]
 ship  | **-f , --find <>**        | shows valid IP and MAC addresses found on file/s            | [find-with-arg]
 ship  | **-g , --gateway**        | shows gateway of online interfaces                          | [gateway]
 ship  | **-h , --help**           | shows this help message                                     | [help]
 ship  | **-H , --hosts**          | shows active hosts on network                               | [hosts]
 ship  | **-HM, --hosts-mac**      | shows active hosts on network with their MAC address        | [hosts-mac]
 ship  | **-i , --interfaces**     | shows active interfaces                                     | [interfaces]
 ship  | **-l , --list**           | shows a list of private and reserved IP addresses           | [list]
 ship  | **-m , --mac**            | shows active interfaces with their MAC address              | [mac]
 ship  | **-n , --neighbor**       | shows neighbor cache                                        | [neighbor]
 ship  | **-P , --port**           | shows a list of common ports                                | [port]
 ship  | **-P , --port <>**        | shows connections to a port per IP                          | [port-with-arg]
 ship  | **-r , --route-ipv4 <>**  | shows the path to a network host using IPv4                 | [route-ipv4-with-arg]
 ship  | **-r6, --route-ipv6 <>**  | shows the path to a network host using IPv6                 | [route-ipv6-with-arg]
 ship  | **-u , --url <>**         | shows valid IP and MAC addresses found on website/s         | [url-with-arg]
 ship  | **-v , --version**        | shows the version of script                                 | [version]
 ship  | **--cidr-4, --cidr-ipv4** | shows active interfaces with their IPv4 address and CIDR    | [cidr-ipv4]
 ship  | **--cidr-6, --cidr-ipv6** | shows active interfaces with their IPv6 address and CIDR    | [cidr-ipv6]
 ship  | **--cidr-a, --cidr-all**  | shows all information with CIDR                             | [cidr-all]
 ship  | **--cidr-l, --cidr-list** | shows a list of private and reserved IP addresses with CIDR | [cidr-list]


### --ipv4

Probably the most common one

Shows the local IPv4 address of each active network interfaces

![ipv4 example][ipv4-img]

### --ipv6

Shows the local IPv6 address of each active network interfaces

![ipv6 example][ipv6-img]

### --all

Use this to display almost all :sweat_smile: useful network information

![all example][all-img]

### --all-interfaces

Displays all kind of network information of the network interfaces, active or not

![all interfaces example][all-interfaces-img]

### --calculate <>

This is an alternative to `ipcalc` and `sipcalc` together

It's under development, but half of their features can be used with ease

![calculate with argument example][calculate-with-arg-img]

To generate HTML code

![calculate with argument html example][calculate-with-arg-html-img]

### --driver

Shows the driver used of each active network interface

![driver example][driver-img]

### --external

Returns your external IP, a.k.a. Public IP

![external example][external-img]

### --external <>

Returns the external IPs of the passed domains

![external with argument example][external-with-arg-img]

#### Additional Info

If you want only the IP address part, you can parse it like that (replace values)

Note that sometimes, multiple values of the same domain are returned. For that reason, you can manipulate the stream with `head` and/or `tail`

```bash
$ bash ship.sh -e DOMAIN_1 DOMAIN_2 DOMAINn | awk '/DOMAIN/{print $1}'
```

### --find <>

Extracts all addresses (IPv4, IPv6 and MAC) from the files specified and pretty prints them on stdout

![find with argument example][find-with-arg-img]

### --gateway

Returns the gateway IP address of each active network interface

![find with argument example][find-with-arg-img]

#### Additional Info

If you want only the IP address part, you can parse it like that (replace value)

```bash
$ bash ship.sh -g | awk '/NAME_OF_NETWORK_INTERFACE/{print $2}'
```

### --help

Forgot something, want to know how to use `ship`, or just a newbie :question:

![help example][help-img]

### --hosts

Pings the entire current network you are connected to, and returns all active hosts (their IPv4 address)

![hosts example][hosts-img]

### --hosts-mac

Pings the entire current network you are connected to, and returns all active hosts (their IPv4 address and their MAC address)

![hosts mac example][hosts-mac-img]

### --interfaces

Returns all active network interfaces

![interfaces example][interfaces-img]

### --list

Returns a list of common IPv4 and IPv6 addresses (bogon IPs)

You can use them to configure your :fire: firewall, or even identify ranges

![list example][list-img]

### --mac

Displays the MAC address of each active network interface

![mac example][mac-img]

#### Additional Info

If you want only the MAC address part, you can parse it like that (replace value)

```bash
$ bash ship.sh -m | awk '/NAME_OF_NETWORK_INTERFACE/{print $2}'
```

### --neighbor

Displays the IPv4 and MAC address of each neighbor (ARP cache)

![neighbor example][neighbor-img]

### --port

Displays a list of common protocols and ports. You can use the list to monitor your network with the argument below this one `--port <>`

![port example][port-img]

### --port <>

Shows all IPv4 addresses you are connected to and how many of them exist by specifying the port. You can use the list above this one `--port` to see which port/s correspond to which protocol

![port with argument example][port-with-arg-img]

### --route-ipv4 <>

Displays step by step, the route to the host specified (IPv4)

![route ipv4 with argument example][route-ipv4-with-arg-img]

### --route-ipv6 <>

Displays step by step, the route to the host specified (IPv6)

Unfortunately, I cannot test upon IPv6 (yet) :cry: the below example shows a snapshot of a machine connected to a non-IPv6 network

![route ipv6 with argument example][route-ipv6-with-arg-img]

### --url <>

Extracts all addresses (IPv4, IPv6 and MAC) from the online documents specified and pretty prints them on stdout

:exclamation: No javascript generated content is displayed

![url with argument example][url-with-arg-img]

### --version

Shows the version of the script with author's information

![version example][version-img]

### --cidr-ipv4

Shows the local IPv4 address of each active network interfaces with CIDR notation

![ipv4 with cidr example][cidr-ipv4-img]

### --cidr-ipv6

Shows the local IPv6 address of each active network interfaces with CIDR notation

![ipv6 with cidr example][cidr-ipv6-img]

### --cidr-all

Use this to display almost all :sweat_smile: useful network information with CIDR notation

![all with cidr example][cidr-all-img]

### --cidr-list

Returns a list of common IPv4 and IPv6 addresses (bogon IPs) with CIDR notation

You can use them to configure your :fire: firewall, or even identify ranges

![list with cidr example][cidr-list-img]

<!-- Anchors -->

[ipv4]: #--ipv4
[ipv4-img]: /imgs/asciicasts/ipv4.gif

[ipv6]: #--ipv6
[ipv6-img]: /imgs/asciicasts/ipv6.gif

[all]: #--all
[all-img]: /imgs/asciicasts/all.gif

[all-interfaces]: #--all-interfaces
[all-interfaces-img]: /imgs/asciicasts/all-interfaces.gif

[calculate-with-arg]: #--calculate-
[calculate-with-arg-img]: /imgs/asciicasts/calculate-with-arg.gif
[calculate-with-arg-html-img]: /imgs/asciicasts/calculate-with-arg-html.gif

[driver]: #--driver
[driver-img]: /imgs/asciicasts/driver.gif

[external]: #--external
[external-img]: /imgs/asciicasts/external.gif

[external-with-arg]: #--external-
[external-with-arg-img]: /imgs/asciicasts/external-with-arg.gif

[find-with-arg]: #--find-
[find-with-arg-img]: /imgs/asciicasts/find-with-arg.gif

[gateway]: #--gateway
[gateway-img]: /imgs/asciicasts/gateway.gif

[help]: #--help
[help-img]: /imgs/asciicasts/help.gif

[hosts]: #--hosts
[hosts-img]: /imgs/asciicasts/hosts.gif

[hosts-mac]: #--hosts-mac
[hosts-mac-img]: /imgs/asciicasts/hosts-mac.gif

[interfaces]: #--interfaces
[interfaces-img]: /imgs/asciicasts/interfaces.gif

[list]: #--list
[list-img]: /imgs/asciicasts/list.gif

[mac]: #--mac
[mac-img]: /imgs/asciicasts/mac.gif

[neighbor]: #--neighbor
[neighbor-img]: /imgs/asciicasts/neighbor.gif

[port]: #--port
[port-img]: /imgs/asciicasts/port.gif

[port-with-arg]: #--port-
[port-with-arg-img]: /imgs/asciicasts/port-with-arg.gif

[route-ipv4-with-arg]: #--route-ipv4-
[route-ipv4-with-arg-img]: /imgs/asciicasts/route-ipv4-with-arg.gif

[route-ipv6-with-arg]: #--route-ipv6-
[route-ipv6-with-arg-img]: /imgs/asciicasts/route-ipv6-with-arg.gif

[url-with-arg]: #--url-
[url-with-arg-img]: /imgs/asciicasts/url-with-arg.gif

[version]: #--version
[version-img]: /imgs/asciicasts/version.gif

[cidr-ipv4]: #--cidr-ipv4
[cidr-ipv4-img]: /imgs/asciicasts/cidr-ipv4.gif

[cidr-ipv6]: #--cidr-ipv6
[cidr-ipv6-img]: /imgs/asciicasts/cidr-ipv6.gif

[cidr-all]: #--cidr-all
[cidr-all-img]: /imgs/asciicasts/cidr-all.gif

[cidr-list]: #--cidr-list
[cidr-list-img]: /imgs/asciicasts/cidr-list.gif
