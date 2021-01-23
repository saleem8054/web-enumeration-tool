Hello Everyone,
I hope you are doing great.
First of all thank you so much for looking into the script.This script is simple and very effective for Recon.I use it daily for my bug bounty.

You will need to download some dependencies before you can run it.

1.ParamSpider https://github.com/devanshbatham/ParamSpider
It helps in finding parameters and endpoints for a given url.It is better and faster than Burp Spider.It functionality matches with waybackurl.

2.Findomain https://github.com/Edu4rdSHL/findomain
As the name suggests,this tool is used to find subdomains.I tried some of the subdomain enumeration scripts but I found this one very effective.

3.Subfinder https://github.com/projectdiscovery/subfinder
Subfinder for extracting maximum subdomains as possible.

3.Eye Witness https://github.com/FortyNorthSecurity/EyeWitness
This tool is use to capture the screenshots of the listed subdomains.This is actually the last part of the script.It also creates some html files which will have screenshots of the subdomain + response headers + IP of the subdomain.

4.Subjack https://github.com/haccer/subjack
It is used for subdomain takeover.

5.Qsreplace https://github.com/tomnomnom/qsreplace
for putting the simple XSS payload in every parameter

Please go to each link and read the documentation and install it.

Put all EyeWitness,findomain and ParamSpider in the same folder as the script(Which I am providing you)

ONE NOTE: You only need to change line 55 in tool.sh a little bit.I am printing line 55 below:

echo "[+] Spidering the sub-domains"
cat $HOME/Desktop/$url/recon/httprobe/alive.txt | xargs -I % python3 $HOME/Desktop/ReconTool/ParamSpider/paramspider.py -l high -o $HOME/Desktop/$url/recon/Spidering/% -d %

as you can see,my ParamSpider script is located in $HOME/Desktop/ReconTool/ParamSpider/paramspider.py,you just need to change the location where you put your ParamSpider script..

