# Research_True_Nmap_Anonymity
<html>

<h6>NOTE</h6>

<h6>Like all of us Linux users, I too am affected by the Firefox memory leak bug. We have very little options for a proper web browsing method and I was forced to resort to the CLI for a lot of my activities. I am googling through Googler, running Git commands on the terminal, and attempting to use HTTRack to view offline versions of web pages.</h6>

<h1>Permitted NMAP to Allow Full Anonymous Scanning</h1>


<h1>Purpose of this article</h1>

<p>The purpose of this article is to dissuade and or put aside any of the ignorance or "hacking guides" i have seen online that preaches the absolutely INCORRECT way of how "to hack" or scan hosts anonymously. Many of these perpetrators have purposefully or recklesskly spread misinformation on social media and YouTube with the intent of boosting their viewership and subscribers and other reasons of personal gain.
</p>
<p>This in turn, misleads tens of thousands of viewers into having a false sense of anonymity and immunity, when in reality, their forensically identifiable information have been logged by professionally installed cybersecurity measures. Had IPv6 been  and success implemented, we wocoded already been toast.
</p>
<p><i>Although, you could say, this was actually some sort of... cloaking tactic done by the perps. It's much harder to go through logs of scriptkiddies if all they see is millions of alert incidents that crashed their servers and flooded their auth.log</i>
</p>
<p>We are going to cover several topics. Including proxy-awareness, nmap's capabilities and limitations, the best traffic hiding protocols, transparent proxies, and how they will all tie together into a "cloaked nmapping package".
</p>
<h1>Proxy Awareness</h1>

<p><a href="https://stackoverflow.com/questions/12753893/what-is-the-definition-of-proxy-aware">https://stackoverflow.com/questions/12753893/what-is-the-definition-of-proxy-aware
</a></p>
<p>Proxy awareness is basically the ability of a application to take advantage of custom proxy settings. Your Firefox web browser is proxy-aware. Subgraph Vega, a vcodenerability scanner for web apps is proxy-aware.</p>

<p>There are actually, a lot of apps that people do not know are NOT proxy aware, for example, Metasploit is not proxy aware unless the app is specifically designed for it.</p>

<p>NMap itself, has only a limited level of proxy-awareness. The remainder of scan types that are not proxy-aware will either not work or simply punch right through the anonymity options of the proxy, revealing your IP, ISP provider, etc. THe discussion in this thread covers most of nmap's limitations in correctly being able to utilize a proxy.</p><p><a href="https://security.stackexchange.com/questions/122561/how-to-use-nmap-through-proxychains">https://security.stackexchange.com/questions/122561/how-to-use-nmap-through-proxychains</a></p>

<p><a href="https://pen-testing.sans.org/resources/papers/gwapt/tunneling-pivoting-web-application-penetration-testing-120229">https://pen-testing.sans.org/resources/papers/gwapt/tunneling-pivoting-web-application-penetration-testing-120229
</a></p>
<p>On Page 14 out of 32, This is a really good explanation of what it means to be proxy-aware. It's a pdf file and and it comes from a  credible source, the SANS research institute. In that article, it explains various pivoting options through a proxy server and SSH tunnels made available by proxies.
</p>
<p>Then on Page 16 out of 32, the article outlines the importance of the --unprivileged option for nmap. Which assumes that nmap does not have the administrative privilege to access a range of ports and raw sockets, in other words, your victim. This option MUST be activated for any direct nmap scans such as CONNECT, or TCP SYN nmap scans.
</p>

<p>A practical situation in which you are required to have '--unprivileged' in the command is for example, logging into a remote router that you have compromised (hacked) and you are looking for fresh targets BEHIND the NAT to attack (pivoting). In this scenario, you must also execute the commands as ROOT, or else the command will throw a error at you.
</p>
<h1>Transparent Proxy</h1>

This is a really good source of the definition of a <u>transparent proxy</u>
<p><a href="https://www.maxcdn.com/one/visual-glossary/transparent-proxy/">https://www.maxcdn.com/one/visual-glossary/transparent-proxy/</a></p>

<p>The selling point of a transparent proxy is that it allows the piping of a NON-PROXY-AWARE app, like nmap for example, into using a proxy server/service. There is no need for a fcodel reconfiguration of the attacking box. You simply run the command through the proxy, which it turn, runs the command through the proxy server, and if all goes well, it SHOcodeD be able to let you offensively scan your targets, anonymously.</p>



<h1>Overview of the True Anonymized Scan Process</h1>

<p>We will install the following apps from our Kali Linux APT repo
</p><code>

<li>  tsocks
</li><li>  tor
</li><li>  proxychains
</li>  <li>nmap</li>
<li>  obfs4proxy
</li>
</code>

<p>Acquire the following ADDITIONAL steps for the Tor services
</p><ol>  Changing from obfs3 to obfs4


<li>  Adding autorun scripts to CRON
</li><li>  Coding our own nmap command bash scripts for easier work
</li>
</ol>
<p>And edit the following files
</p><code>  /etc/proxychains.conf


<li>  /etc/tsocks.conf
</li><li>  /etc/tor/torrc
</li>
</code>

<h1>How the syntax works.</h1>


<code>
<li>"tsocks" turns on a transparent proxy for nmap
</li><li>"proxychains", if set to listen to port 9050 as shown at the bottom of this page, will pipe all nmap traffic through port 9050, which is connected to tor
</li><li>"/etc/proxychains.conf", is configured to pipe Tor traffic through the obfs4proxy listener. which adds another layer of obfuscation options to cloak your traffic.
</li><li>"--dns-servers", sets the DNS to google, because as we are proxychaining to Tor, we also lose the ability to resolve URL addresses.
</li><li>"-iL" sets a list of hosts/targets to scan. Keep this in the same directory level as this script.
</li><li>"nmap_scan_list.txt" sets a list of scripts to use. You can change this as you wish, all nmap scripts are located at /usr/share/nmap/scripts
</li></code>


<p><h1>installation guide. APT command for linux systems</h1></p>

<code><p>sudo apt-get install -y tor tsocks obfs4proxy proxychains</p></code>

<p>acquire your bridge info and login in this link. Requires captcha completion
</p>
<p><a href="https://bridges.torproject.org/bridges?transport=obfs4">https://bridges.torproject.org/bridges?transport=obfs4</a></p>

<h1>with this information in hand, please go right ahead and modify your config files as shown below
</h1>
<p><a href="/etc/tor/torrc">/etc/tor/torrc</a>
</p>
<p>add this to the top line in file
<code>
<li>  UseBridges 1
</li>
<li>Bridge obfs4 {BridgeIP:Port} {key}
</li>
<li>ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy --managed --enableLogging
</li>
<li>Bridge obfs4 1{BridgeIP:Port} {key}
</li>
<li>ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy --managed --enableLogging
</li>
<li>Bridge obfs4 {BridgeIP:Port} {key}
</li>
<li>ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy --managed --enableLogging</p>
</li></code>

<p><a href="/etc/proxychains.conf">/etc/proxychains.conf</a>
</p><p>defaults set to "tor"

<code>

<li>socks5 	127.0.0.1 9050
</li><li>socks4	127.0.0.1 9050
</li><li>#proxy_dns (comment out)
</li>
</code>


</p>
<a href="/etc/tsocks.conf">/etc/tsocks.conf
</a><p>
<code>
<li>server = 127.0.0.1
</li><li>server_type = 5
</li><li>server_port = 9050
</li></code>
</p>

<p>In the event that you failed to listen to my instructions, then the default server_port = 1080, which means the traffic will NOT be routed through Tor, and NOT be anonymized by the proxy services, and therefore, be forensically identifiable as clear as day.
</p>
<h1><p>Your actual nmap command</p>
</h1>

<code><p>/bin/bash tsocks proxychains nmap {parameters} &</p>
</code>
<p>We use bash because bash allows us to specify the & option versus the standard /bin/sh allowing most commands to run in the background. Alternatively for logging purposes...</p>


<code><p>/bin/bash tsocks proxychains nmap {parameters} &| tee -a /var/log/nmap.log
</p></code>


<h1>Other resources.
</h1>

<p>Located in this git repo is a script that I made called "true_anon_scan.sh" that does the following things. It is meant to be run as "/bin/bash true_anon_scan.sh"
</p>
<ol>

<li>For each scan type script in nmap_scan_list.txt
</li><li>For each listed target in list_of_hosts.txt
</li><li>Runs a scan of each type... FIN, XMAS, and COMPREHENSIVE
</li><li>Logs the data as a *.xml file (usable by metasploit)
</li><li>And at the end of all of the scans, runs Metasploit db_import to import all of the data
</li>
</ol>

<p>If used as a cronjob, it will automatically run a vulnerability scan through the proxies.
</p>
</html>
