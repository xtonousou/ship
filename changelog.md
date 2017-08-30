---
layout: default
---

# Change Log
All notable changes to this project will be documented in this file.

## [2.6.2] - 2017-08-18
### Added
* `ship -e` now can handle more than one domain.
  * e.g. `ship -e github.com google.com facebook.com`

### Changed
* **Fixed** an issue displaying weird output when parsing HTML.
  * e.g. `ship -u github.com google.com facebook.com`
* Minor changes on code.
* Refactored `README.md`.
* Refactored `GUIDE.md`.

## [2.6.1] - 2017-07-22
### Added
* [Official website](https://xtonousou.github.io/ship).

### Changed
* Refactored `README.md`.
* Minor changes on code.

## [2.6] - 2017-06-15
### Added
* Message to show that the **ipv6** module is not loaded.
  * This can be suppressed by piping `tail -n+2`
* Feature to show all network interfaces.
* **Fixed** wrong color output on version message.

### Changed
* **Fixed** wrong outputs of IPv6 addresses.
* **Fixed** wrong way to check IPv6 availability.
* **Fixed** issues with temporary files and background jobs.
* Logo on version output.
* MAC and IPv6 addresses are now printed in lower case for better readability.
* Refactored code a bit.

## [2.5] - 2017-03-07
### Added
* IP calculation feature can now show information without binary (optional).
* IP calculation feature can now be shown in HTML5 format (optional).

### Changed
* **Fixed** `ss` output.
* **Fixed** IP address outputs on different distributions.
* **Fixed** `awk` outputs on Kali Linux.
* **Fixed** ip calculation feature for older bash versions.
* Minor code clean up.
* Minor code improvements.
* Checking functions for **IPv6** compatibility and bash version validation.

### Removed
* Warnings with `shellcheck`.

## [2.4] - 2017-02-17
### Added
* Converting functions (Binary to Decimal, Binary to Hexadecimal, Decimal to Binary) to be used in other functions.
* "Show network, broadcast address, netmask, CIDR, Cisco wildcard, class, host range, maximum hosts from given IP address".
 * Seriously why need to install `ipcalc sipcalc`, when you can do this with pure Bash?
* Show a list of private and reserved IP addresses (IPv4 and IPv6) with or without CIDR notation (Bogon IPs).
* More sources to grab user's public IP.
  * Randomly choose from 6 different web sources to grab the IP.

### Changed
* **Fixed** wrong output of active connection/s based on port.
* **Fixed** "Show neighbor cache" feature.
* **Fixed** file/s and online document/s sorting methods and output.
* "Usage" output.
* "Show version" output.
* Beautified README.

## [2.3] - 2017-01-27
### Added
* Functionality to pass multiple arguments at the same time.
 * `ship -f file1 file2 fileN` or drag and drop each file.
 * `ship -u url1 url2 urlN`.
* `set -o xtrace` for debugging.
* `trap` for cleaning temp files.

### Changed
* **Fixed** issues when 'pinging' the host from complex URL (stream edit).
* **Fixed** issues when 'pinging' a network host who does not accept ICMP packets.
* **Fixed** issues when 'pinging' an invalid network host.
* **Fixed** weird behavior when showing wireless driver used.
* **Fixed** wrong IPv6 checking.
* Timeout values to match slow connections.
* Speed and performance improvements.
* Code improvements.
* Shebang for better portability.
* Commands' parameters to long ones for better readability.
* Static references to dynamic ones (e.g. script's name).
* Avoid piping `grep` to `awk`.
* Variable groups to arrays.
* Concatenation methods.
* README.

### Removed
* Errors and warnings using `shellcheck`.
* Unused functions.

## [2.2] - 2017-01-14
### Added
* Driver info on `ship --all` and `ship --cidr-a`.

### Changed
* Fixed `ship --external`.
* Replaced `printf` with `echo` on some options for better quality and external use.
* Usage for better readability.
* README.

## [2.1] - 2017-01-11
### Changed
* Code flow a bit.
* Issue template `.github/ISSUE_TEMPLATE.md`.
* **Fixed** [#26](https://github.com/xtonousou/shIP/issues/26).
* Compressed head.png for less usage.
* README.

## [2.0] - 2017-01-03
### Added
* Created issue template `.github/ISSUE_TEMPLATE.md` (thanks v1s1t0r1sh3r3 for the tip).
* Created pull request template `.github/PULL_REQUEST_TEMPLATE.md`.

### Changed
* Usage.
* Simplified everything.
* Smoother code flow.
* Many features of `ship` like location, avg RTT, bandwidth can be found on [old](https://github.com/xtonousou/shIP/tree/old) branch.
* **Fixed** weird permissions' bug while creating-deleting `/tmp/ship` files.
* **Fixed** different issues while searching for network addresses in a file or a website.

### Removed
* Spinner on long running tasks.
* Tools: `kill bc ping6`.
* Many of `ship` actions:
  * shows connection bandwidth to different locations.
  * shows results of scans for malicious activities of {URL}.
  * shows location info of {USER|DOMAIN}.
  * shows the download and upload speed in kB/s.
  * shows the average RTT to {IPV4|DOMAIN}.
  * shows the average RTT to {IPV6|DOMAIN}.

## [1.9] - 2016-11-20
### Added
* Spinner on long running tasks (requires `kill` from `util-linux`).
* More tested *Arch Linux* versions.

### Changed
* *README.md*.
* Minor code improvements.
* Shortened timeout to *20sec* while checking with `wget --spider`.
* **Fixed** file permissions.

## [1.8] - 2016-11-14
### Added
* Find valid IPv4, IPv6 and MAC addresses from a URL `ship -U <URL>` or `ship --url <URL>`.
* Find valid IPv4, IPv6 and MAC addresses from a file `ship -f <file>` or `ship --find <file>`.
* Comments to explain logic on complicated statements.

### Changed
* Usage.
* Cleaning on exit function.
* Some strings.
* Appearance of `ship -S` or `ship --speed`.
* Minimum bash requirement from `4.0` to `3.2`.
* Minor code improvements e.g. `sort -V | uniq` to `sort -Vu`.

### Removed
* Ugly dialogs and the space on start of each line.
* Root permission for scanning alive hosts with MAC `ship -HM` or `ship --hosts-mac`.
* Tools: `arping`, `pr`.

## [1.7] - 2016-10-29
### Added
* Method to print the driver used of each active network interface: `ship -d` , `ship --driver`.
* Timeout while getting http code, in `wget` commands.
* Extract IPv4 and IPv6 addresses from a file.
* Bash version checking function.
* **INT** and **SIGTSTP** trapping (exit confirmation).

## Changed
* Code is now completely clean. Using `shellcheck` tool.
* Code improvements.
* Method to store active network interfaces into arrays.
* Some dialogs on bandwidth testing functions.

## [1.6] - 2016-10-25
### Added
* More locations to test bandwidth.
* Monitor **download** and **upload speed** of online network interface.
* Increased performance by handling background tasks properly.
* Show results of scans for **malicious activities** of a domain.
* Show internet connection **bandwidth** to CDN and different locations.
* Show the path to a network host (IPv4 or IPv6).

## Changed
* README.
* Usage.
* Some dialogs.
* Uppercase MAC and IPv6 addresses.
* `ship -F {DOMAIN|IP}` now shows multiple IPs (maximum 15).
* **Fixed** issue [#17](https://github.com/xtonousou/shIP/issues/17).
* **Fixed** when `ship -L` or `ship -F` input had a lot of suffixes with slashes, it showed user's info.
* **Fixed** some issues when IPv6 is used.

## Removed
* Tools: `lsmod` now using `cat /proc/modules`.

## [1.5] - 2016-10-09
### Added
* Function to handle sleeping time (depends on number of CPU cores).

## Changed
* Usage.
* Dialogs.
* Increase performance.
* Method to find active hosts on network. Multithreaded `ping arping`.
* Method to find external IP or location.
* Regex to extract IPv4 and MAC address in some functions.
* **Fixed** Ubuntu cannot grab info with `ip`.
* **Fixed** Ubuntu cannot parse domain to find location info.
* **Fixed** Kali prints other info with `arping`.

### Removed
* Tools: `nmap netstat netcat`.

## [1.4] - 2016-10-07
### Added
* Show ARP cache.
* Show location info of a domain. Map location image provided.

### Changed
* Usage.
* `gawk` to `awk`
* Method for grabbing IPv4 address of user, domain. Now using `netcat`. 
* **Fixed** some user input 'bugs'. 
* **Fixed** regex for domain and IP validation. 
* Order of commands in functions. 
* Execution speed increased by a little.
* Checking methods.
* Dialogs and messages.
* Position of functions based on usage for better readability.

## [1.3] - 2016-10-05
### Added
* Get the local IPv6 directly.
* Get full location info of a domain or IP in same command.
* Get the quantity of connections to a port per IP with `netstat`.

### Changed
* Usage.
* Get external IPv4 and resolve domain's IPv4 in same command.
* Code is cleaner and more user-friendly.

## [1.2] - 2016-10-04
### Added
* Get the IP address from a domain.
* Get the local IP address directly.
* New dialogs.
* Some functions for better flow.
* Comments.

### Changed
* Usage.
* Method to check connectivity (local or network).
* Source to ping.
* Parameter passing.
* Clean up code.

### Removed
* Tools: `curl route`.

## [1.1] - 2016-10-01
### Added
* Display script's version.
* Display of default gateway of online interfaces.
* Host discovery (two methods).

### Changed
* Usage.
* Renamed some things.
* Fixed some quotes and brackets.

## [1.0] - 2016-09-29
### Added
* Display of active interfaces.
* Display of IPv4, IPv6 and MAC addresses of active interfaces with or without CIDR.
* Display of public IP.
* Measure the response time from google.com.
