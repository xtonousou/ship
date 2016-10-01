#shIP (aka. show IP)
A simple, handy network multitool that shows the IPv4, IPv6, MAC addresses of your active network interfaces and many more.<br/>
<img src="https://raw.githubusercontent.com/xtonousou/shIP/master/imgs/head.png" title="SAIL!"/>

##Features

###Basic
- Show active network interfaces.<br/>
- Show **IPv4** addresses of active network interfaces with or without **CIDR**.<br/>
- Show **IPv6** addresses of active network interfaces with or without **CIDR**.<br/>
- Show **MAC** addresses of active network interfaces.<br/>

###Miscellaneous
- Show public IP.<br/>
- Show average response time from google.com.</br>
- Show active hosts on current network.</br>

##Requirements
Essential tools:</br>
**```ip route ping curl lsmod hash printf echo head tail tr cut grep awk sed```**</br>
Optional tools:</br>
**```nmap```**</br>

Tested on **Arch Linux 4.7.5-1** with **bash 4.3.46**.

##Under development
- [ ] Alternative method to ping and measure average response time.
- [ ] Finding active hosts nearby on current network.

##LICENSE
This script is under GPLv3 (or later) License.</br>

####Any kind of help is welcome.</br>
