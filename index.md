---
layout: home
---

### [](#header-3) Features

* Show all network **interfaces**
* Show all active network **interfaces**
* Show the **driver** used of each active network interface
* Show the **gateway** of each online interface
* Show the addresses of each active network interface with or without CIDR notation
  * **IPv4**
  * **IPv6** (*if possible*)
  * **MAC**
* Show the **public/external IP/s**
  * of current user
  * of website/s or domain/s
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
  * split into networks of size n1, n2, n3 🚧
  * deaggregate address range 🚧
* Show list of **common ports** with description, **private** and **reserved** IPv4 and IPv6 addresses with or without CIDR notation
* Compatible with most of the common linux distributions
* Drag and drop URLs or file paths on console window
* Cleaning temp files and handling remaining tasks on exit
* Exiting on long running tasks needs confirmation

---      

### [](#header-3) Usage

Read the [Guide](guide)

---

### [](#header-3) Requirements

`ship` uses some of the tools included in **coreutils** and shell builtins

#### [](#header-4) Mandatory

 🔧   | Package      
:-----|:-------------
 awk  | awk \| gawk  
 grep | grep         
 ip   | iproute2     
 ping | iputils      
 sed  | sed          
 ss   | iproute2     
 wget | wget         

#### [](#header-4) Mandatory Choice

One or more of the following tools must be installed

 🔧         | Package      
:-----------|:-------------
 mtr        | mtr          
 tracepath  | iputils      
 traceroute | traceroute   

#### [](#header-4) NOTE

`ship` utilizes the functionality of `ping` to check and validate LAN and WAN connections

* **CAP_NET_RAW** capability should be permitted
* Kernel must support non-raw ICMP sockets
* User must be allowed to create ICMP echo sockets

---

### [](#header-3) Compatibility

 🐧     | Version             
:-------|:--------------------
 Arch   | 4.7.5-1 - 4.12.8-2  
 CentOS | 7                   
 Debian | 7 - 8               
 Kali   | 2016.2              
 Ubuntu | 14.04.3 - 16.04.1   

---

### [](#header-3) Getting Started

```bash
$ git clone --branch=master https://github.com/xtonousou/ship.git
$ cd /path/to/ship
$ bash ship.sh
```

#### [](#header-4) Arch Linux

```bash
$ yaourt -S ship
$ ship
```

---

### [](#header-3) Checksums

#### `master` branch

> MD5: 12bfc2455a348b2b660de95017076706

> SHA1: 306fd0db6b8c40357c043223c43e1660bbf60ab2

#### `dev` branch

> MD5: 3242abd56e4b709955530de0240ee672

> SHA1: 7ca97759563b4b9c95fd10076bd72df642874d7b

---

### [](#header-3) Contribution

Pull requests, issues, suggestions, testing and feedback are all welcome

Please read [this](contributing) article first, about code of conduct

* Fork the repo
* Create a new branch
  * `$ git checkout -b my-new-feature`
* Make the appropriate changes in the files
* Add changes to reflect the changes made
* Commit your changes
  * `$ git commit -am 'Added some feature'`
* Push to the branch
  * `$ git push origin my-new-feature`
* Create a Pull Request on `dev`

---

### [](#header-3) Changelog

Read the [Changelog](changelog) file to review changes

---

### [](#header-3) Contact

Send me an email at [xtonousou@gmail.com](mailto:xtonousou@gmail.com)

----

### [](#header-3) License

Copyright (c) **2017** by **Sotirios M. Roussis**. Some rights reserved


`ship` is under the terms of the GPLv3+ License, following all clarifications stated in the [license](license.md) file
