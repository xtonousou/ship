# shIP (aka. show IP) [![License](https://img.shields.io/badge/License-GPL%20v3%2B-blue.svg?style=flat-square)](https://raw.githubusercontent.com/xtonousou/shIP/master/LICENSE)
A simple, handy network addressing multitool with plenty features.
![alt text](https://raw.githubusercontent.com/xtonousou/shIP/master/imgs/head.png "SAIL!")

## Features

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
<!--- should change URL below after merge with master -->
**Bash [3.2](http://www.tldp.org/LDP/abs/html/bashver3.html#AEN20987 "View changelog.") or later.**

    Possible package name   Tools
    ├── awk gawk            ├── awk  
    ├── coreutils           ├── cat cut echo id paste printf rm sort split tail timeout touch uniq
    ├── grep                ├── grep
    ├── iproute2            ├── ip ss
    ├── mtr                 ├── mtr
    ├── iputils             ├── ping tracepath
    ├── sed                 ├── sed
    ├── traceroute          ├── traceroute
    └── wget                └── wget

## Tested On

| Distribution | Version            |
|--------------|--------------------|
| Ubuntu       | 14.04.3 - 16.04.1  |
| Debian       | 7 - 8              |
| Kali         | 2016.2             |
| Arch         | 4.7.5-1 - 4.8.13-1 |

## :scroll: Changelog

Be sure to check out [this](https://github.com/xtonousou/shIP/blob/master/CHANGELOG.md).

## Getting Started

* Method one (**recommended**)
  * `wget -q https://raw.githubusercontent.com/xtonousou/shIP/master/ship.sh`
  * `bash ship.sh`
* Method two (for the lazy ones)
  * `wget -q https://raw.githubusercontent.com/xtonousou/shIP/master/ship.sh && bash ship.sh`
* Method three
  * `wget -q https://raw.githubusercontent.com/xtonousou/shIP/master/ship.sh`
  * `chmod +x ship.sh` need root privileges
  * `./ship.sh`
* Method four (clone repository)
  * `git clone https://github.com/xtonousou/shIP.git`
  * `cd /path/to/shIP`
  * `bash ship.sh`

## :octocat: Contribution

* More distributions support compatibility.
* Suggestions, new features.
* Testing and feedback.

You can send an email to `xtonousou@gmail.com` or submit a pull request.

If you choose to submit a pull request, make sure you read all needed [information](https://github.com/xtonousou/shIP/blob/master/.github/PULL_REQUEST_TEMPLATE.md) first.

## LICENSE
This script is under GPLv3 (or later) License.
