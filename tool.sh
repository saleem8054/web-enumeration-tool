#!/bin/bash

url=$1

arr=(${url//./ })
length=${#arr[@]}
TLD=${arr[$length-1]}
	

if [ ! -d "/root/Desktop/$url" ];then
	mkdir /root/Desktop/$url
fi
if [ ! -d "/root/Desktop/$url/recon" ];then
	mkdir /root/Desktop/$url/recon
fi
#    if [ ! -d '/root/Desktop/$url/recon/eyewitness' ];then
#        mkdir /root/Desktop/$url/recon/eyewitness
#    fi
if [ ! -d "/root/Desktop/$url/recon/Spidering" ];then
	mkdir /root/Desktop/$url/recon/Spidering
fi
if [ ! -d "/root/Desktop/$url/recon/httprobe" ];then
	mkdir /root/Desktop/$url/recon/httprobe
fi
if [ ! -d "/root/Desktop/$url/recon/potential_takeovers" ];then
	mkdir /root/Desktop/$url/recon/potential_takeovers
fi
if [ ! -f "/root/Desktop/$url/recon/httprobe/alive.txt" ];then
	touch /root/Desktop/$url/recon/httprobe/alive.txt
fi
if [ ! -f "/root/Desktop/$url/recon/final.txt" ];then
	touch /root/Desktop/$url/recon/final.txt
fi
 
echo "[+] Harvesting subdomains with finddomain..."
./findomain-linux -t $url >> /root/Desktop/$url/recon/assets.txt
cat /root/Desktop/$url/recon/assets.txt | grep $1 >> /root/Desktop/$url/recon/final.txt
rm /root/Desktop/$url/recon/assets.txt
 
 
echo "[+] Probing for alive domains..."
cat /root/Desktop/$url/recon/final.txt | sort -u | httprobe -s -p https:443 -c 64 | sed 's/https\?:\/\///' | tr -d ':443'  >> /root/Desktop/$url/recon/httprobe/a.txt
sort -u /root/Desktop/$url/recon/httprobe/a.txt > /root/Desktop/$url/recon/httprobe/alive.txt
rm /root/Desktop/$url/recon/httprobe/a.txt
 
echo "[+] Checking for possible subdomain takeover..."
 
if [ ! -f "/root/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt" ];then
	touch /root/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt
fi
 
subjack -w /root/Desktop/$url/recon/final.txt -t 100 -timeout 30 -ssl -c /go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o /root/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt

echo "[+] Spidering the sub-domains"
cat /root/Desktop/$url/recon/httprobe/alive.txt | xargs -I % python3 /app/ParamSpider/paramspider.py --level high -o /root/Desktop/$url/recon/Spidering/% -d %

echo "[+] Doing some extra works"
sleep 3
rm -rf /root/Desktop/$url/recon/Spidering/$url
cat /root/Desktop/$url/recon/Spidering/*.$TLD > /root/Desktop/$url/recon/Spidering/AllParams.txt
cat /root/Desktop/$url/recon/Spidering/AllParams.txt | qsreplace '"/><img src=x onerror=confirm(1)>' > /root/Desktop/$url/recon/Spidering/XSSParameters.txt

echo "[+] Taking Screenshots"
./EyeWitness/Python/EyeWitness.py --threads 100 --web --timeout 150  -f  /root/Desktop/$url/recon/httprobe/alive.txt -d /root/Desktop/$url/recon/EyeWitness



