# Change Log
All notable changes to this project will be documented in this file.<br/>

## [1.5] - 2016-10-09
### Added
- Function to handle sleeping time (depends on number of CPU cores).<br/>

## Changed
- Dialogs.<br/>
- Increase performance.<br/>
- Method to find active hosts on network. Multithreaded ```ping arping```.<br/>
- Method to find external IP or location.<br/>
- Regex to extract IPv4 and MAC address in some functions.<br/>
- **Fixed** Ubuntu cannot grab info with ```ip```.<br/>
- **Fixed** Ubuntu cannot parse domain to find location info.<br/>
- **Fixed** Kali prints other info with ```arping```.<br/>

### Changed
- Usage.<br/>
- Method to check connectivity (local or network).<br/>
- Source to ping.<br/>
- Parameter passing.<br/>
- Clean up code.<br/>

### Removed
- Tools: **```nmap netstat netcat```**<br/>

## [1.4] - 2016-10-07
### Added
- Show ARP cache.<br/>
- Show location info of a domain. Map location image provided.<br/>

### Changed
- Usage.<br/>
- **```gawk```** --> **```awk```**
- Method for grabbing IPv4 address of user, domain. Now using **```netcat```**.<br/> 
- **Fixed** some user input 'bugs'.<br/> 
- **Fixed** regex for domain and IP validation.<br/> 
- Order of commands in functions.<br/> 
- Execution speed increased by a little.<br/>
- Checking methods.<br/>
- Dialogs and messages.<br/>
- Position of functions based on usage for better readability.<br/>

## [1.3] - 2016-10-05
### Added
- Get the local IPv6 directly.<br/>
- Get full location info of a domain or IP in same command.<br/>
- Get the quantity of connections to a port per IP with **```netstat```**.<br/>

### Changed
- Usage.<br/>
- Get external IPv4 and resolve domain's IPv4 in same command.<br/>
- Code is cleaner and more user-friendly.<br/>

## [1.2] - 2016-10-04
### Added
- Get the IP address from a domain.<br/>
- Get the local IP address directly.<br/>
- New dialogs.<br/>
- Some functions for better flow.<br/>
- Comments.<br/>

### Changed
- Usage.<br/>
- Method to check connectivity (local or network).<br/>
- Source to ping.<br/>
- Parameter passing.<br/>
- Clean up code.<br/>

### Removed
- Tools: **```curl route ```**<br/>

## [1.1] - 2016-10-01
### Added
- Display script's version.<br/>
- Display of default gateway of online interfaces.<br/>
- Host discovery (two methods).<br/>

### Changed
- Usage.<br/>
- Renamed some things.<br/>
- Fixed some quotes and brackets.<br/>

## [1.0] - 2016-09-29
### Added
- Display of active interfaces.<br/>
- Display of IPv4, IPv6 and MAC addresses of active interfaces with or without CIDR.<br/>
- Display of public IP.<br/>
- Measure the response time from google.com.<br/>
