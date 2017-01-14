# :ship: shIP (aka. show IP) [![License](https://img.shields.io/badge/License-GPL%20v3%2B-blue.svg?style=flat-square)](LICENSE.md)
A simple, handy network addressing multitool with plenty features.
![alt text](imgs/head.png "SAIL!")

## :anchor: Features

* Show active network **interfaces**.
* Show the **driver** used of each active network interface.
* Show **gateway** of online interfaces.
* Show **MAC** addresses of active network interfaces.
* Show **IPv4/IPv6** addresses of active network interfaces with or without **CIDR**.
* Show **external IP** of user or **external IPs** of a **domain**.
* Show active **hosts** on current network with or without **MAC** address.
* Show all valid **IPv4**, **IPv6** and **MAC** addresses extracted from a **file**.
* Show all valid **IPv4**, **IPv6** and **MAC** addresses extracted from a **website**.
* Show the network **path** to a host. IPv4/IPv6.

## Requirements
**Bash [3.2](http://www.tldp.org/LDP/abs/html/bashver3.html#AEN20987 "View changelog.") or later.**

| Tool                                                               | Possible package name |
|--------------------------------------------------------------------|-----------------------|
| awk                                                                | awk / gawk            |
| cat cut echo id paste printf rm sort split tail timeout touch uniq | coreutils             |
| grep                                                               | grep                  |
| ip ss                                                              | iproute2              |
| mtr                                                                | mtr                   |
| ping tracepath                                                     | iputils               |
| sed                                                                | sed                   |
| traceroute                                                         | traceroute            |
| wget                                                               | wget                  |

**Tested on** :penguin: :

    Distribution    Version
    ├── Ubuntu      ├── 14.04.3 - 16.04.1
    ├── Debian      ├── 7 - 8
    ├── Kali        ├── 2016.2
    └── Arch        └── 4.7.5-1 - 4.8.13-1

## :page_with_curl: Changelog

Be sure to check out [this](CHANGELOG.md).

## :computer: Getting Started

* Method one (**recommended**)
  * `wget -q https://raw.githubusercontent.com/xtonousou/shIP/master/ship.sh`
  * `bash ship.sh`
* Method two
  * `wget -q https://raw.githubusercontent.com/xtonousou/shIP/master/ship.sh`
  * `chmod +x ship.sh` (need root privileges)
  * `./ship.sh`
* Method three (clone repository)
  * `git clone https://github.com/xtonousou/shIP.git`
  * `cd /path/to/shIP`
  * `bash ship.sh`

Replace `master` on URL with the preferred branch.

## :octocat: Contribution

More distributions support compatibility.<br/>
Suggestions, new features.<br/>
Testing and feedback.<br/>

* Choices
  * Send an :e-mail: to `xtonousou@gmail.com`.
  * Submit a pull request.

If you choose to submit a pull request, make sure you read all needed [information](.github/PULL_REQUEST_TEMPLATE.md) first. :books:

## :scroll: LICENSE
This script is under GPLv3 (or later) [License](LICENSE.md).
