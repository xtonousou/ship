<p align="center"><img width=10% src="/imgs/ship.png"></img></p>
<p align="center">ship is a simple, handy network addressing multitool with plenty of features</p>
<p align="center">
  <a href="ship.sh"><img src="https://img.shields.io/badge/version-2.6-blue.svg?style=flat-square&colorA=4488BB&colorB=95A5A5"></a>
    &nbsp;
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-GPL%20v3%2B-yellow.svg?style=flat-square&colorA=4488BB&colorB=95A5A5"></a>
    &nbsp;
  <a href="http://tldp.org/LDP/abs/html/bashver3.html#AEN20987"><img src="https://img.shields.io/badge/bash-3.2+-lightgrey.svg?style=flat-square&colorA=4488BB&colorB=95A5A5"></a>
    &nbsp;
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NJ4VLBTM8FB4C"><img src="https://img.shields.io/badge/paypal-donate-blue.svg?style=flat-square&colorA=4488BB&colorB=95A5A5"></a>
    &nbsp;
  <a href="https://aur.archlinux.org/packages/ship/"><img src="https://img.shields.io/aur/version/ship.svg?style=flat-square&colorA=4488BB&colorB=95A5A5"></a>
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

<table>
  <tr><th>:wrench:</th>  <th>Package Name</th></tr>
  <tr><td>awk</td>       <td>awk | gawk</td></tr>
  <tr><td>grep</td>      <td>grep</td></tr>
  <tr><td>ip</td>        <td>iproute2</td></tr>
  <tr><td>mtr</td>       <td>mtr</td></tr>
  <tr><td>ping</td>      <td>iputils</td></tr>
  <tr><td>sed</td>       <td>sed</td></tr>
  <tr><td>ss</td>        <td>iproute2</td></tr>
  <tr><td>tracepath</td> <td>iputils</td></tr>
  <tr><td>traceroute</td><td>traceroute</td></tr>
  <tr><td>wget</td>      <td>wget</td></tr>
</table>

<table>
  <tr>
    <td>
      It is required to have at least one of the following tools: <b>mtr</b> | <b>tracepath</b> | <b>traceroute</b>
      The script uses standard commands included in <b>coreutils</b> and shell builtins so they are not checked
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
 Arch      | 4.7.5-1 - 4.10.13-1 
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

### Licenses

 :page_with_curl:                                          | Description                                    
:---------------------------------------------------------:|:----------------------------------------------:
 [![GPLv3+IMG]](LICENSE.md)                                | This script is under [GPLv3+] license          
 [![CC3+IMG]](http://creativecommons.org/licenses/by/4.0/) | Graphic made by [madebyoliver] from [Flaticon] 

<!-- Links -->
[Guide]: GUIDE.md
[Changelog]: CHANGELOG.md
[madebyoliver]: http://www.flaticon.com/authors/madebyoliver
[Flaticon]: http://www.flaticon.com/
[GPLv3+]: LICENSE.md
[GPLv3+IMG]: http://gplv3.fsf.org/gplv3-127x51.png
[CC3+IMG]: https://licensebuttons.net/l/by/3.0/88x31.png
