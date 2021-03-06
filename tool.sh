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
mkdir $HOME/Desktop/$url/recon/Broken_Links
mkdir $HOME/Desktop/$url/recon/ClickJacking
touch $HOME/Desktop/$url/recon/httprobe/alive.txt
touch $HOME/Desktop/$url/recon/final.txt
touch $HOME/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt
 
echo "[+] Harvesting subdomains with finddomain..."
./findomain-linux -t $url --quiet -r > $HOME/Desktop/$url/recon/finddomain.txt

echo "[+] Harvesting subdomains with subfinder..."
subfinder -d $url --silent -t 200 -nW -all > $HOME/Desktop/$url/recon/subfinder.txt

echo "[+] Maximising subdomains count..."
cat $HOME/Desktop/$url/recon/subfinder.txt $HOME/Desktop/$url/recon/finddomain.txt | sort -u | egrep -iv "(www.$url)" > $HOME/Desktop/$url/recon/httprobe/alive.txt
sleep 1

echo "[+] Checking for possible subdomain takeover..."
subfinder -d $url --silent -t 200 -all > $HOME/Desktop/$url/recon/final.txt
subjack -w $HOME/Desktop/$url/recon/final.txt -t 200 -timeout 30 -m -a -ssl -v -o $HOME/Desktop/$url/recon/potential_takeovers/potential_takeovers.txt

echo "[+] Checking CNAME records for subdomain takeover..."
for domain in $(cat $HOME/Desktop/$url/recon/final.txt); do dig $domain | grep CNAME >> $HOME/Desktop/$url/recon/DNS/CNAME.txt; done
 
echo "[+] Spidering the sub-domains"
cat $HOME/Desktop/$url/recon/httprobe/alive.txt | xargs -I % python3 ./ParamSpider/paramspider.py --level high -o $HOME/Desktop/$url/recon/Spidering/% -d %

echo "[+] Doing some extra works"
sleep 1
cat $HOME/Desktop/$url/recon/Spidering/*.$TLD > $HOME/Desktop/$url/recon/Spidering/AllParams.txt
cat $HOME/Desktop/$url/recon/Spidering/AllParams.txt | qsreplace > $HOME/Desktop/$url/recon/Spidering/XSSParameters.txt


echo "[+] Taking Screenshots"
./EyeWitness/Python/EyeWitness.py --threads 100 --web --timeout 150  -f  $HOME/Desktop/$url/recon/httprobe/alive.txt -d $HOME/Desktop/$url/recon/EyeWitness

echo "[+] Checking ClickJacking vulnerabilities..."
python3 ./clickjack/clickjack.py $HOME/Desktop/$url/recon/httprobe/alive.txt
mv ./clickjack/Vulnerable.txt $HOME/Desktop/$url/recon/ClickJacking

echo "[+] Checking Broken links..."
for domain in $(cat $HOME/Desktop/$url/recon/httprobe/alive.txt)
do
	linkcheck -e $domain | egrep -iv "($domain|200|300|301|- redirect path:|Access to these URLs denied by robots.txt, so we couldn't check them:)" | sed -r '/^\s*$/d' | tee $HOME/Desktop/$url/recon/Broken_Links/$domain
done

