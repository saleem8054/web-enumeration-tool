Hello Everyone,
I hope you are doing great.
First of all thank you so much for looking into the script.This script is simple and very effective for Recon.I use it daily for my bug bounty.

### You will need to download some dependencies before you can run it.

1.ParamSpider https://github.com/devanshbatham/ParamSpider
It helps in finding parameters and endpoints for a given url and it's subdomains. It is better and faster than Burp Spider.It functionality matches with waybackurl.

2.Findomain https://github.com/Edu4rdSHL/findomain
This tool is use to find subdomains.I tried some of the subdomain enumeration scripts, however, I found this one very effective.

3.Subfinder https://github.com/projectdiscovery/subfinder
Subfinder for extracting maximum subdomains as possible.

3.Eye Witness https://github.com/FortyNorthSecurity/EyeWitness
This tool is use to capture the screenshots of the listed subdomains.It also creates html files which will have screenshots of the subdomain + response headers + IP of the subdomain.

4.Subjack https://github.com/haccer/subjack
It is use to check for subdomain takeover.

5.Qsreplace https://github.com/tomnomnom/qsreplace
It is use for removing duplicates and attaching simple XSS payloads in the urls obtained through waybackurl machine.

6.linkcheck https://github.com/filiph/linkcheck
It checks for broken links for all the subdomains.

7.clickjack https://github.com/saleem8054/clickjack
It checks for clickjacking vulnerabilities for all the subdomains.

### Please go to each link and read the documentation and install it.

### Put EyeWitness,findomain,ParamSpider and clickjack scripts in the same folder where you placed your tool.sh script.

### Example

##### Input

```
./tool.sh pubg.com
```

### HAPPY HACKING.
