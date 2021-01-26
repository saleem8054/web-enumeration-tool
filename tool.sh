#!/bin/bash

url=$1

arr=(${url//./ })
length=${#arr[@]}
TLD=${arr[$length-1]}
	

if [ ! -d "$HOME/Desktop/$url" ];then
	mkdir $HOME/Desktop/$url
else
	rm -rf $HOME/Desktop/$url
	mkdir $HOME/Desktop/$url
fi
mkdir $HOME/Desktop/$url/recon
mkdir $HOME/Desktop/$url/recon/Spidering
mkdir $HOME/Desktop/$url/recon/httprobe
mkdir $HOME/Desktop/$url/recon/potential_takeovers
mkdir $HOME/Desktop/$url/recon/DNS
touch $HOME/Desktop/$url/recon/httprobe/alive.txt
touch $HOME/Desktop/$url/recon/final.txt
touch $HOME/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt
 
echo "[+] Harvesting subdomains with finddomain..."
./findomain-linux -t $url --quiet -r > $HOME/Desktop/$url/recon/finddomain.txt

echo "[+] Harvesting subdomains with subfinder..."
subfinder -d $url --silent -nW -all > $HOME/Desktop/$url/recon/subfinder.txt

echo "[+] Checking the maximum sub domains count"
sleep 1
findDomainCount=$(cat $HOME/Desktop/$url/recon/finddomain.txt | wc -l)
subFinderCount=$(cat $HOME/Desktop/$url/recon/subfinder.txt |  wc -l)
finalFile=""

if [ $findDomainCount -gt $subFinderCount ]
then
	rm $HOME/Desktop/$url/recon/subfinder.txt
	finalFile="finddomain.txt"
elif [ $findDomainCount -lt $subFinderCount ]
then
	rm $HOME/Desktop/$url/recon/finddomain.txt
	finalFile="subfinder.txt"
else
	rm $HOME/Desktop/$url/recon/finddomain.txt
	finalFile="subfinder.txt"
fi	

cat $HOME/Desktop/$url/recon/$finalFile | grep $1 > $HOME/Desktop/$url/recon/httprobe/alive.txt
rm $HOME/Desktop/$url/recon/$finalFile

echo "[+] Checking for possible subdomain takeover..."
subfinder -d $url --silent -t 100 -all > $HOME/Desktop/$url/recon/final.txt
subjack -w $HOME/Desktop/$url/recon/final.txt -t 100 -timeout 30 -ssl -c $HOME/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $HOME/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt

echo "[+] Checking CNAME records for subdomain takeover..."
for domain in $(cat $HOME/Desktop/$url/recon/final.txt); do dig $domain | grep CNAME >> $HOME/Desktop/$url/recon/DNS/CNAME.txt; done
 
echo "[+] Spidering the sub-domains"
cat $HOME/Desktop/$url/recon/httprobe/alive.txt | xargs -I % python3 $HOME/Desktop/ReconTool/ParamSpider/paramspider.py --level high -o $HOME/Desktop/$url/recon/Spidering/% -d %

echo "[+] Doing some extra works"
sleep 1
rm $HOME/Desktop/$url/recon/Spidering/$url
cat $HOME/Desktop/$url/recon/Spidering/*.$TLD > $HOME/Desktop/$url/recon/Spidering/AllParams.txt
cat $HOME/Desktop/$url/recon/Spidering/AllParams.txt | qsreplace '=' > $HOME/Desktop/$url/recon/Spidering/XSSParameters.txt


echo "[+] Taking Screenshots"
./EyeWitness/Python/EyeWitness.py --threads 100 --web --timeout 150  -f  $HOME/Desktop/$url/recon/httprobe/alive.txt -d $HOME/Desktop/$url/recon/EyeWitness


