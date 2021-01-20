#!/bin/bash

url=$1

arr=(${url//./ })
length=${#arr[@]}
TLD=${arr[$length-1]}
	

if [ ! -d "$HOME/Desktop/$url" ];then
	mkdir $HOME/Desktop/$url
fi
if [ ! -d "$HOME/Desktop/$url/recon" ];then
	mkdir $HOME/Desktop/$url/recon
fi
#    if [ ! -d '$HOME/Desktop/$url/recon/eyewitness' ];then
#        mkdir $HOME/Desktop/$url/recon/eyewitness
#    fi
if [ ! -d "$HOME/Desktop/$url/recon/Spidering" ];then
	mkdir $HOME/Desktop/$url/recon/Spidering
fi
if [ ! -d "$HOME/Desktop/$url/recon/httprobe" ];then
	mkdir $HOME/Desktop/$url/recon/httprobe
fi
if [ ! -d "$HOME/Desktop/$url/recon/potential_takeovers" ];then
	mkdir $HOME/Desktop/$url/recon/potential_takeovers
fi
if [ ! -f "$HOME/Desktop/$url/recon/httprobe/alive.txt" ];then
	touch $HOME/Desktop/$url/recon/httprobe/alive.txt
fi
if [ ! -f "$HOME/Desktop/$url/recon/final.txt" ];then
	touch $HOME/Desktop/$url/recon/final.txt
fi
 
echo "[+] Harvesting subdomains with finddomain..."
./findomain-linux -t $url --quiet >> $HOME/Desktop/$url/recon/finddoamin.txt
#cat $HOME/Desktop/$url/recon/finddoamin.txt | grep $1 >> $HOME/Desktop/$url/recon/final.txt
#rm $HOME/Desktop/$url/recon/finddoamin.txt

echo "[+] Harvesting subdomains with subfinder..."
subfinder -d $url --silent >> $HOME/Desktop/$url/recon/subfinder.txt
#cat $HOME/Desktop/$url/recon/subfinder.txt | grep $1 >> $HOME/Desktop/$url/recon/final2.txt
#rm $HOME/Desktop/$url/recon/subfinder.txt

echo "[+] Checking the maximum sub domains count"
sleep 1
findDomainCount=$(cat $HOME/Desktop/$url/recon/finddoamin.txt | wc -l)
subFinderCount=$(cat $HOME/Desktop/$url/recon/subfinder.txt |  wc -l)
finalFile=""

if [ $findDomainCount -gt $subFinderCount ]
then
	rm $HOME/Desktop/$url/recon/subfinder.txt
	finalFile="finddomain.txt"
elif [ $findDomainCount -lt $subFinderCount ]
then
	rm $HOME/Desktop/$url/recon/finddoamin.txt
	finalFile="subfinder.txt"
else
	rm $HOME/Desktop/$url/recon/finddoamin.txt
	finalFile="subfinder.txt"
fi	

cat $HOME/Desktop/$url/recon/$finalFile | grep $1 >> $HOME/Desktop/$url/recon/final.txt
rm $HOME/Desktop/$url/recon/$finalFile

 
 
echo "[+] Probing for alive domains..."
cat $HOME/Desktop/$url/recon/final.txt | sort -u | httprobe -s -p https:443 -c 64 | sed 's/https\?:\/\///' | tr -d ':443'  >> $HOME/Desktop/$url/recon/httprobe/a.txt
sort -u $HOME/Desktop/$url/recon/httprobe/a.txt > $HOME/Desktop/$url/recon/httprobe/alive.txt
rm $HOME/Desktop/$url/recon/httprobe/a.txt
 
echo "[+] Checking for possible subdomain takeover..."
 
if [ ! -f "$HOME/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt" ];then
	touch $HOME/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt
fi
 
subjack -w $HOME/Desktop/$url/recon/final.txt -t 100 -timeout 30 -ssl -c $HOME/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $HOME/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt

echo "[+] Spidering the sub-domains"
cat $HOME/Desktop/$url/recon/httprobe/alive.txt | xargs -I % python3 $HOME/Desktop/ReconTool/ParamSpider/paramspider.py --level high -o $HOME/Desktop/$url/recon/Spidering/% -d %

echo "[+] Doing some extra works"
sleep 1
rm $HOME/Desktop/$url/recon/Spidering/$url
cat $HOME/Desktop/$url/recon/Spidering/*.$TLD > $HOME/Desktop/$url/recon/Spidering/AllParams.txt
cat $HOME/Desktop/$url/recon/Spidering/AllParams.txt | qsreplace '=' > $HOME/Desktop/$url/recon/Spidering/XSSParameters.txt


echo "[+] Taking Screenshots"
./EyeWitness/Python/EyeWitness.py --threads 100 --web --timeout 150  -f  $HOME/Desktop/$url/recon/httprobe/alive.txt -d $HOME/Desktop/$url/recon/EyeWitness



