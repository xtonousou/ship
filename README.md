<p align="center"><img width=35% src="/imgs/logo-with-text.png"></img></p>
<p align="center">a simple, handy network addressing multitool with plenty of features</p>
<p align="center">
  <a href="ship.sh"><img src="https://img.shields.io/badge/version-2.6-blue.svg?style=flat-square&colorA=30a7ad&colorB=8cfdff"></a>
    &nbsp;
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-GPL%20v3%2B-yellow.svg?style=flat-square&colorA=30a7ad&colorB=8cfdff"></a>
    &nbsp;
  <a href="http://tldp.org/LDP/abs/html/bashver3.html#AEN20987"><img src="https://img.shields.io/badge/bash-3.2+-lightgrey.svg?style=flat-square&colorA=30a7ad&colorB=8cfdff"></a>
    &nbsp;
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NJ4VLBTM8FB4C"><img src="https://img.shields.io/badge/paypal-donate-blue.svg?style=flat-square&colorA=30a7ad&colorB=8cfdff"></a>
    &nbsp;
  <a href="https://aur.archlinux.org/packages/ship/"><img src="https://img.shields.io/aur/version/ship.svg?style=flat-square&colorA=30a7ad&colorB=8cfdff"></a>
</p>

---

### Features

* Show all network **interfaces**
* Show all active network **interfaces**
* Show the **driver** used of each active network interface
* Show the **gateway** of each online interface
* Show the addresses of each active network interface with or without CIDR notation
  * **IPv4**
  * **IPv6** (*if possible*)
  * **MAC**
* Show the **public/external IP/s**
  * of user
  * of website / domain
* Show **active hosts** on current network with or without MAC address
* Show all valid addresses (IPv4, IPv6, MAC) extracted
  * from **file** or multiple **files** at once
  * from **website** or multiple **websites** at once
* Show the **route** to a network host using three most common tools. `ship` checks which are installed and decides to run the fastest one for each case scenario
  * **IPv4**
  * **IPv6** (*if possible*)
* Show the **broadcast** and **network** address, cisco **wildcard** mask, **class** and **host range** by giving the IP address and CIDR or netmask
  * **IPv4**
  * optionally suppress the bitwise output
  * display results as HTML
* Show list of **common ports** with description, **private** and **reserved** IPv4 and IPv6 addresses with or without CIDR notation
* Compatible with most of the common linux distributions
* Drag and drop URLs or file paths on console window
* Cleaning temp files and handling remaining tasks on exit
* Exiting on long running tasks needs confirmation

---      

### Usage

Read the [Guide]. Usage and some interactive examples are there for you :ship:

---

### Requirements

 :wrench:   | Package     
:-----------|:------------
 awk        | awk | gawk  
 grep       | grep        
 ip         | iproute2    
 mtr        | mtr         
 ping       | iputils     
 sed        | sed         
 ss         | iproute2    
 tracepath  | iputils     
 traceroute | traceroute  
 wget       | wget        

<table>
  <tr>
    <td>
      It is required to have at least one of the following tools: <b>mtr</b> | <b>tracepath</b> | <b>traceroute</b></br>
      The script uses standard commands included in <b>coreutils</b> and shell builtins so they are not checked</b></br>
      It also uses <b>ping</b> to check, test and validate connection and network hosts, it requires <b>CAP_NET_RAW</b> capability to be executed
    </td>
  </tr>
</table>

* Kernel must support non-raw ICMP sockets
* User must be allowed to create ICMPs echo sockets

---

### Compatibility

 :penguin: | Version             
:----------|:--------------------
 Arch      | 4.7.5-1 - 4.11.6-3  
 Debian    | 7 - 8               
 Kali      | 2016.2              
 Ubuntu    | 14.04.3 - 16.04.1   

---

### Getting Started

```bash
$ git clone --branch=master https://github.com/xtonousou/ship.git
$ cd /path/to/ship
$ bash ship.sh
```

#### Arch Linux

```bash
$ yaourt -S ship
```

---

### Contribution

Pull requests, issues, suggestions, testing and feedback are all welcome

* Fork the repo
* Create a new branch
  * `$ git checkout -b my-new-feature`
* Make the appropriate changes in the files
* Add changes to reflect the changes made
* Commit your changes
  * `$ git commit -am 'Added some feature'`
* Push to the branch
  * `$ git push origin my-new-feature`
* Create a Pull Request

---

### Changelog

Read the [Changelog] file to review changes

---

### Contact

Send me an email at [xtonousou@gmail.com]

----

### License

Copyright (c) **2017** by **Sotirios M. Roussis**. Some rights reserved


`ship` is under the terms of the GPLv3+ License, following all clarifications stated in the [license] file

<!-- Links -->

[Guide]: GUIDE.md
[Changelog]: CHANGELOG.md
[license]: LICENSE.md
