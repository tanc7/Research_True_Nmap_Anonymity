#!/bin/bash
SHELL="/bin/bash"

clear
echo "Restarting Tor, and by that, restarting obfs4proxy"
service tor restart
echo "Sleeping for 10 seconds"
sleep 10

echo "Running netstat -antp for tor and obfs4 services"
netstat -antp | egrep -i 'tor|obfs' &


proxy_type="--proxy 127.0.0.1:9050"
scan_begin_FIN="tsocks proxychains nmap -v -O -sF -Pn -T4 -O -F --script="
scan_begin_XMAS="tsocks proxychains nmap -v -O -sX -Pn -T4 -O -F --script="
scan_begin_COMP="tsocks proxychains nmap -sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 --script="
scan_end="--dns-servers 8.8.8.8,8.8.4.4 -iL list_of_hosts.txt >> shell_script_output.log &"
script_list="nmap_scan_list.txt"
scan_output="-oX /mnt/Data1"
privilege_level="--unprivileged"

# designed to prove my point. It runs a packet capture while the scans are running, and then stops it and opens it with wireshark
pkt_capture_test_script="tcpdump -i eth0 -w /root/Desktop/test_proxy_chains.pcap"
pkt_capture_test_script_stop="killall -9 tcpdump"
pkt_capture_open="wireshark /root/Desktop/test_proxy_chains.pcap"

for script_chosen in $(cat $script_list)
  do
    echo "Selected: $script_chosen Type: $script_chosen "
    echo "Type: $script_chosen  FIN"
    $scan_begin_FIN $script_chosen $scan_output/"$script_chosen.xml" $scan_end
    echo "Type: $script_chosen  XMAS"
    $scan_begin_XMAS $script_chosen $scan_output/"$script_chosen.xml" $scan_end
    echo "Type: $script_chosen  COMPREHENSIVE"
    $scan_begin_COMP $script_chosen $scan_output/"$script_chosen.xml" $scan_end
    # echo "Completed: FIN+XMAS+COMP Scans using $script_chosen, file is $scan_output/"$script_chosen.xml""
  done

msfconsole -x cd $scan_output;db_import *.xml
$pkt_capture_test_script_stop
$pkt_capture_open


# configruation guide.

########################### installation guide. APT command for linux systems ######################################
# sudo apt-get install -y tor tsocks obfs4proxy proxychains

# acquire your bridge info and login in this link. Requires captcha completion
# https://bridges.torproject.org/bridges?transport=obfs4

# with this information in hand, please go right ahead and modify your config files as shown below

########################## /etc/tor/torrc #########################################
# add this to the top line in file

# UseBridges 1
# Bridge obfs4 BridgeIP:Port <key>
# ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy --managed --enableLogging
# Bridge obfs4 1BridgeIP:Port <key>
# ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy --managed --enableLogging
# Bridge obfs4 BridgeIP:Port <key>
# ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy --managed --enableLogging

########################### /etc/proxychains.conf #############################################
# defaults set to "tor"
# socks5 	127.0.0.1 9050
# socks4	127.0.0.1 9050
## proxy_dns (comment out)
################### /etc/tsocks.conf ##############################

# server = 127.0.0.1
# server_type = 5
# server_port = 9050


######################### Your actual nmap command ##############################

# /bin/bash tsocks proxychains nmap <parameters> &
#
# We use bash because bash allows us to specify the & option versus the standard /bin/sh. Alternatively for logging purposes
#
# /bin/bash tsocks proxychains nmap <parameters> &| tee -a /var/log/nmap.log
