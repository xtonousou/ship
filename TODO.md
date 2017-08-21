## TODO

A list of features to be implemented in the near future.

### Features

* Fingerprint / Identify Remote Web Server
  * [ ] 
  * `telnet` or `curl`
    * `telnet 192.168.1.1 www`
    * `curl -I 192.168.1.1`
  * Resources
    * [cyberciti](https://www.cyberciti.biz/faq/find-out-remote-webserver-name/)
* Suppress / Ignore Warning Messages
  * [ ]
  * `-s`, `--suppress` or `-q`, `--quiet`
* Refactor code in order to be more scalable
  * [ ]
  * Messages like *Pinging host please wait ...* should be removed or suppressed
* Implement GET / POST requests with `curl` for scraping websites in order to extract network addresses. This solves XHR protected hosts. Javascript generated content will NOT be implemented because `ship` will bloat from dependencies.
  * [ ]
* Replace `wget` with `curl`
  * [ ]
