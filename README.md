<p align="center"><img width=10% src="/imgs/ship-text.png"></img></p>
<p align="center"><img width=20% src="/imgs/ship-logo.png"></p>
<p align="center">shIP (aka. show IP) is a simple, handy network addressing multitool with plenty of features.</p>
<p align="center">
  <a href="ship.sh"><img src="https://img.shields.io/badge/version-2.3-blue.svg?style=flat-square"></a>
    &nbsp;
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-GPLv3%2B-yellow.svg?style=flat-square"></a>
    &nbsp;
  <a href="http://tldp.org/LDP/abs/html/bashver3.html#AEN20987"><img src="https://img.shields.io/badge/bash-3.2%20or%20later-lightgrey.svg?style=flat-square"></a>
    &nbsp;
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NJ4VLBTM8FB4C"><img src="https://img.shields.io/badge/paypal-donate-blue.svg?style=flat-square"></a>
    &nbsp;
  <a href="https://www.gitcheese.com/app/#/projects/211c47d3-9fff-4fe9-b067-45ee9c9a2151/pledges/create"><img src="https://api.gitcheese.com/v1/projects/211c47d3-9fff-4fe9-b067-45ee9c9a2151/badges"></a>
</p>

---

### Features

* Show all active network **interfaces**
* Show the **driver** used of each active network interface
* Show the **gateway** of each online interface
* Show the addresses of each active network interface with or without [CIDR]
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
* Compatible with most of the common linux distributions
* Drag and drop URLs or file paths on console window
* Cleaning temp files and handling remaining tasks on exit
* <kbd>Ctrl+C</kbd> needs confirmation on long running tasks

---

### Requirements

 :wrench:   | Package Name 
------------|--------------
 awk        | awk / gawk   
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
      It is required to have at least one of the following tools: <i>mtr tracepath traceroute</i>.
      The script uses standard commands included in <i>coreutils</i> and shell builtins so they are not checked.
      It also uses <i>ping</i> to check, test and validate connection and network hosts, it requires <b>CAP_NET_RAW</b> capability to be executed.
    </td>
  </tr>
</table>

* Kernel must support non-raw ICMP sockets
* User must be allowed to create ICMPs echo sockets

---

### Compatibility

 :penguin: | Version            
-----------|-------------------
 Arch      | 4.7.5-1 - 4.9.6-1  
 Debian    | 7 - 8              
 Kali      | 2016.2             
 Ubuntu    | 14.04.3 - 16.04.1  

---

### Changelog

Read [Changelog] file to review changes.

---

### Getting Started

* Method one (**recommended**)
  * `wget -q https://raw.githubusercontent.com/xtonousou/shIP/master/ship.sh`
  * `bash ship.sh`
* Method two
  * `wget -q https://raw.githubusercontent.com/xtonousou/shIP/master/ship.sh`
  * `chmod +x ship.sh` (need **root** privileges)
  * `./ship.sh`
* Method three (clone repository)
  * `git clone https://github.com/xtonousou/shIP.git`
  * `cd /path/to/shIP`
  * `bash ship.sh`

Replace `master` on URL with the preferred branch.

---

### Contribution

Pull requests, issues, suggestions, testing and feedback are all welcome.

* Fork the repo
* Create a new branch
 * `git checkout -b my-new-feature`
* Make the appropriate changes in the files
* Add changes to reflect the changes made
* Commit your changes
 * `git commit -am 'Added some feature'`
* Push to the branch
 * `git push origin my-new-feature`
* Create a Pull Request

---

### Contact

Send me an email at [xtonousou@gmail.com].

----

### License

[![GPLv3+IMG]](LICENSE.md)
This script is under [GPLv3+] license.

<!-- Links -->
[Changelog]: CHANGELOG.md
[GPLv3+]: LICENSE.md
[CIDR]: https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
[GPLv3+IMG]: http://gplv3.fsf.org/gplv3-127x51.png
