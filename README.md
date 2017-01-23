# :ship: shIP (aka. show IP) [![License](https://img.shields.io/badge/License-GPL%20v3%2B-blue.svg?style=flat-square)](LICENSE.md)
![](imgs/head.png "SAIL!")
<p align="center">
A simple, handy network addressing multitool with plenty features.
</p>

## :ocean: Features

* Show all active network **interfaces**
* Show the **driver** used of each active network interface
* Show the **gateway** of each online interface
* Show the addresses of each active network interface with or without [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
 * **IPv4**
 * **IPv6** (*if possible*)
 * **MAC**
* Show the **public/external IP/s**
 * of user
 * of website / domain
* Show **active hosts** on current network with or without MAC address
* Show all valid addresses (IPv4, IPv6, MAC)
 * from a **file**
 * from a **website**
* Show the **route** to a network host
 * **IPv4**
 * **IPv6** (*if possible*)
* Compatible with most of the common linux distributions
* Drag and drop URLs or file paths on console window
* Cleaning temp files and handling remaining tasks on exit
* Exit needs confirmation on long running tasks

## :anchor: Requirements

![](imgs/bash.gif)

| Tool           | Possible package name | Tool           | Possible package name |
|:---------------|:----------------------|:---------------|:----------------------|
| awk            | awk / gawk            | ping tracepath | iputils               |
| grep           | grep                  | sed            | sed                   |
| ip ss          | iproute2              | traceroute     | traceroute            |
| mtr            | mtr                   | wget           | wget                  |

The script also uses standard tools included in `coreutils` so they are not checked, <br/>
e.g. (cat cut echo id paste printf rm sort split tail timeout touch uniq).

## :penguin: Compatibility

| Distribution        | Version            |
|:--------------------|:-------------------|
| Arch                | 4.7.5-1 - 4.8.13-1 |
| Debian              | 7 - 8              |
| Kali                | 2016.2             |
| Ubuntu              | 14.04.3 - 16.04.1  |

The script uses `ping` to check, test and validate connection and network hosts, it requires **CAP_NET_RAW** capability to be executed.

* Kernel must support non-raw ICMP sockets
* User must be allowed to create ICMPs echo sockets

## :page_with_curl: Changelog

Check out [this](CHANGELOG.md).

## :computer: Getting Started

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

## :octocat: Contribution

I welcome pull requests, issues, suggestions, testing and feedback.

* Fork it
* Create your feature branch
 * `git checkout -b my-new-feature`
* Commit your changes
 * `git commit -am 'Added some feature'`
* Push to the branch
 * `git push origin my-new-feature`
* Create new Pull Request

If you choose to create new pull request, make sure you read all needed [information](.github/PULL_REQUEST_TEMPLATE.md) first.

## :speech_balloon: Contact

Send me an email to `xtonousou@gmail.com`.

## :scroll: License

This script is under GPLv3 (or later) [License](LICENSE.md).
