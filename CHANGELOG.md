# Change Log
All notable changes to this project will be documented in this file.<br/>

## [2.0] - 2017-01-03
### Added
* Created issue template `.github/ISSUE_TEMPLATE.md` (thanks @v1s1t0r1sh3r3 for the tip).<br/>

### Changed
* Usage.<br/>
* Simplified everything.<br/>
* Smoother code flow.<br/>
* Many features of `ship` like location, avg RTT, bandwidth can be found on [old](https://github.com/xtonousou/shIP/tree/old) branch.<br/>
* **Fixed** weird permissions' bug while creating-deleting `/tmp/ship` files.<br/>
* **Fixed** different issues while searching for network addresses in a file or a website.<br/>

### Removed
* Spinner on long running tasks.<br/>
* Tools: `kill bc ping6`.<br/>
* Many of `ship` actions:<br/>
  * shows connection bandwidth to different locations.<br/>
  * shows results of scans for malicious activities of {URL}.<br/>
  * shows location info of {USER|DOMAIN}.<br/>
  * shows the download and upload speed in kB/s.<br/>
  * shows the average RTT to {IPV4|DOMAIN}.<br/>
  * shows the average RTT to {IPV6|DOMAIN}.<br/>

## [1.9] - 2016-11-20
### Added
* Spinner on long running tasks (requires `kill` from `util-linux`).<br/>
* More tested *Arch Linux* versions.<br/>

### Changed
* *README.md*.<br/>
* Minor code improvements.<br/>
* Shortened timeout to *20sec* while checking with `wget --spider`.<br/>
* **Fixed** file permissions.<br/>

## [1.8] - 2016-11-14
### Added
* Find valid IPv4, IPv6 and MAC addresses from a URL `ship -U <URL>` or `ship --url <URL>`.<br/>
* Find valid IPv4, IPv6 and MAC addresses from a file `ship -f <file>` or `ship --find <file>`.<br/>
* Comments to explain logic on complicated statements.<br/>

### Changed
* Usage.<br/>
* Cleaning on exit function.<br/>
* Some strings.<br/>
* Appearance of `ship -S` or `ship --speed`.<br/>
* Minimum bash requirement from `4.0` to `3.2`.<br/>
* Minor code improvements e.g. `sort -V | uniq` to `sort -Vu`.<br/>

### Removed
* Ugly dialogs and the space on start of each line.<br/>
* Root permission for scanning alive hosts with MAC `ship -HM` or `ship --hosts-mac`.<br/>
* Tools: `arping`, `pr`.<br/>

## [1.7] - 2016-10-29
### Added
* Method to print the driver used of each active network interface: `ship -d` , `ship --driver`.<br/>
* Timeout while getting http code, in `wget` commands.<br/>
* Extract IPv4 and IPv6 addresses from a file.<br/>
* Bash version checking function.<br/>
* **INT** and **SIGTSTP** trapping (exit confirmation).<br/>

## Changed
* Code is now completely clean. Using `shellcheck` tool.<br/>
* Code improvements.<br/>
* Method to store active network interfaces into arrays.<br/>
* Some dialogs on bandwidth testing functions.<br/>

## [1.6] - 2016-10-25
### Added
* More locations to test bandwidth.<br/>
* Monitor **download** and **upload speed** of online network interface.<br/>
* Increased performance by handling background tasks properly.<br/>
* Show results of scans for **malicious activities** of a domain.<br/>
* Show internet connection **bandwidth** to CDN and different locations.<br/>
* Show the path to a network host (IPv4 or IPv6).<br/>

## Changed
* README.<br/>
* Usage.<br/>
* Some dialogs.<br/>
* Uppercase MAC and IPv6 addresses.<br/>
* `ship -F {DOMAIN|IP}` now shows multiple IPs (maximum 15).<br/>
* **Fixed** issue [#17](https://github.com/xtonousou/shIP/issues/17).<br/>
* **Fixed** when `ship -L` or `ship -F` input had a lot of suffixes with slashes, it showed user's info.<br/>
* **Fixed** some issues when IPv6 is used.<br/>

## Removed
* Tools: `lsmod` now using `cat /proc/modules`.<br/>

## [1.5] - 2016-10-09
### Added
* Function to handle sleeping time (depends on number of CPU cores).<br/>

## Changed
* Usage.<br/>
* Dialogs.<br/>
* Increase performance.<br/>
* Method to find active hosts on network. Multithreaded `ping arping`.<br/>
* Method to find external IP or location.<br/>
* Regex to extract IPv4 and MAC address in some functions.<br/>
* **Fixed** Ubuntu cannot grab info with `ip`.<br/>
* **Fixed** Ubuntu cannot parse domain to find location info.<br/>
* **Fixed** Kali prints other info with `arping`.<br/>

### Removed
* Tools: `nmap netstat netcat`.<br/>

## [1.4] - 2016-10-07
### Added
* Show ARP cache.<br/>
* Show location info of a domain. Map location image provided.<br/>

### Changed
* Usage.<br/>
* `gawk` to `awk`
* Method for grabbing IPv4 address of user, domain. Now using `netcat`.<br/> 
* **Fixed** some user input 'bugs'.<br/> 
* **Fixed** regex for domain and IP validation.<br/> 
* Order of commands in functions.<br/> 
* Execution speed increased by a little.<br/>
* Checking methods.<br/>
* Dialogs and messages.<br/>
* Position of functions based on usage for better readability.<br/>

## [1.3] - 2016-10-05
### Added
* Get the local IPv6 directly.<br/>
* Get full location info of a domain or IP in same command.<br/>
* Get the quantity of connections to a port per IP with `netstat`.<br/>

### Changed
* Usage.<br/>
* Get external IPv4 and resolve domain's IPv4 in same command.<br/>
* Code is cleaner and more user-friendly.<br/>

## [1.2] - 2016-10-04
### Added
* Get the IP address from a domain.<br/>
* Get the local IP address directly.<br/>
* New dialogs.<br/>
* Some functions for better flow.<br/>
* Comments.<br/>

### Changed
* Usage.<br/>
* Method to check connectivity (local or network).<br/>
* Source to ping.<br/>
* Parameter passing.<br/>
* Clean up code.<br/>

### Removed
* Tools: `curl route`.<br/>

## [1.1] - 2016-10-01
### Added
* Display script's version.<br/>
* Display of default gateway of online interfaces.<br/>
* Host discovery (two methods).<br/>

### Changed
* Usage.<br/>
* Renamed some things.<br/>
* Fixed some quotes and brackets.<br/>

## [1.0] - 2016-09-29
### Added
* Display of active interfaces.<br/>
* Display of IPv4, IPv6 and MAC addresses of active interfaces with or without CIDR.<br/>
* Display of public IP.<br/>
* Measure the response time from google.com.<br/>
