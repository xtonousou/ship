## TODO

A list of features to be implemented in the near future.

### Features

* Fingerprint / Identify Remote Web Server
  * [] 
  * `telnet` or `curl`
    * `telnet 192.168.1.1 www`
    * `curl -I 192.168.1.1`
  * Resources
    * [cyberciti](https://www.cyberciti.biz/faq/find-out-remote-webserver-name/)
* Suppress / Ignore Warning Messages
  * []
  * `-s`, `--suppress` or `-q`, `--quiet`
* Refactor code in order to be more scalable
  * []
  * Messages like *Pinging host please wait ...* should be removed or suppressed
* Implement GET / POST requests with `curl` for scraping websites in order to extract network addresses. Javascript generated content will NOT be implemented because `ship` will be bloated with dependencies.
  * []
* Replace `wget` with `curl`
  * []
* Implement a list of IP ranges per country. Read [this](http://www.iwik.org/ipcountry/)
* Remove the utilization of those tools: `traceroute tracepath mtr` and completely depend on [here](https://intodns.com). Scrape properly the website and edit the appropriate stream. Maybe need to find more of these hosts, to decrease the chance of not getting data due to host's issues.
* IP Location info using the following API
  * [ip2country](https://ip2country.info/)
