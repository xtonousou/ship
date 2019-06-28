<p align="center"><img width=50% src="/imgs/logo-with-text.png"></img></p>
<p align="center">a simple, handy network addressing multitool with plenty of features</p>
<p align="center">
  <a href="ship.sh"><img src="https://img.shields.io/badge/version-2.6.3-blue.svg?style=flat-square&colorA=13818d&colorB=44c2c7"></a>
    &nbsp;
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-GPL%20v3%2B-yellow.svg?style=flat-square&colorA=13818d&colorB=44c2c7"></a>
    &nbsp;
  <a href="http://tldp.org/LDP/abs/html/bashver3.html#AEN20987"><img src="https://img.shields.io/badge/bash-3.2+-lightgrey.svg?style=flat-square&colorA=13818d&colorB=44c2c7"></a>
    &nbsp;
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NJ4VLBTM8FB4C"><img src="https://img.shields.io/badge/paypal-donate-blue.svg?style=flat-square&colorA=13818d&colorB=44c2c7"></a>
    &nbsp;
  <a href="https://saythanks.io/to/xtonousou"><img src="https://img.shields.io/badge/say%20thanks-!-blue.svg?style=flat-square&colorA=13818d&colorB=44c2c7"></a>
    &nbsp;
  <a href="https://aur.archlinux.org/packages/ship/"><img src="https://img.shields.io/aur/version/ship.svg?style=flat-square&colorA=13818d&colorB=44c2c7"></a>
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
* Show the vendor name of MAC address/es (*needs internet connection*)
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
  * split into networks of size n1, n2, n3 :construction:
  * deaggregate address range :construction:
* Show a list of **common ports** with description, **private** and **reserved** IPv4 and IPv6 addresses with or without CIDR notation
* Configuration FLAGS to change behavior, color theme and verbosity
  * `COLOR`: choose a color theme from 1 to 4
  * `SILENT`: choose `1` to skip checking, warning and error messages (not critical, useful on scripting)
  * `NOCHECK`: choose `1` to skip validation and checking functions (faster, expects well-formatted inputs)
  * `DEBUG`: choose `1` to enter debugging mode a.k.a. trace mode
* Multiple flags can also be used
  * e.g. `COLOR=3 SILENT=1 NOCHECK=1 bash ship.sh -h`
* **Compatible with almost any linux distribution**
* Drag and drop URLs or file paths on console window
* Cleaning temp files and handling remaining tasks on exit
* Exiting on long running tasks needs confirmation

---

### Usage

Read the [Guide] :mortar_board:

---

### Requirements

`ship` uses some of the tools included in **coreutils** and shell builtins

#### Mandatory

 :wrench:   | Package
:-----------|:------------------------
 awk        | awk \| gawk
 grep       | grep
 ip         | iproute2
 ping       | iputils \| iputils-ping
 sed        | sed
 ss         | iproute2
 wget       | wget

#### Mandatory Choice

One of the following tools must be installed. If more than one is installed `ship` will use the fastest one

 :wrench:   | Package
:-----------|:-------------
 mtr        | mtr
 tracepath  | iputils
 traceroute | traceroute

---

### Compatibility (tested)

 :penguin:  | Version
:-----------|:--------------------
 Arch       | 4.7.5-1 - 4.16.13-2
 Black Arch | 2017.12.11
 CentOS     | 7
 Debian     | 7 - 8
 Kali       | 2016.2
 Ubuntu     | 14.04.3 - 16.04.1

---

### Getting Started

```bash
$ git clone --branch=master --depth 1 https://github.com/xtonousou/ship.git
$ cd /path/to/ship
$ bash ship
```

#### Arch Linux

```bash
$ yaourt -S ship
$ ship
```

---


### Contribution

Pull requests, issues, suggestions, testing and feedback are all welcome :octocat:

Please read [this] article first, about code of conduct

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

### Changelog

Read the [Changelog] file to review changes :scroll:

---

### About `ship`

* [ToadLeap] - *04/07/2018*
* [HelpuGroup] - *02/06/2018*
* [MakeTechEasier] - *Unknown*
* [WonderHowTo/NullByte] - *12/22/2017*
* [root.cz] - *08/30/2017*

---

### License

Copyleft (&#8580;) **2017** by **Sotirios M. Roussis**. Some rights reserved


`ship` is under the terms of the GPLv3+ License, following all clarifications stated in the [license] file

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fxtonousou%2Fship.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fxtonousou%2Fship?ref=badge_large)

<!-- Links -->

[this]: CODE_OF_CONDUCT.md
[Guide]: https://xtonousou.github.io/ship/guide
[Changelog]: CHANGELOG.md
[license]: LICENSE.md

[ToadLeap]: https://toadleap.com/linux-basics-for-the-aspiring-hacker-using-ship-for-quick-handy-ip-address-information/
[HelpuGroup]: https://helpugroup.ru/osnovy-linux-chast-30-ispolzovanie-ship-dlya-bystrogo-polucheniya-informatsii-ob-ip-adresah-v-udobnom-vide/
[MakeTechEasier]: https://www.maketecheasier.com/software/ship-sh/
[WonderHowTo/NullByte]: https://null-byte.wonderhowto.com/how-to/linux-basics-for-aspiring-hacker-using-ship-for-quick-handy-ip-address-information-0181593/
[root.cz]: https://www.root.cz/clanky/softwarova-sklizen-30-8-2017
