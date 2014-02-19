ARP Inspector
=============

Simple web interface for finding machines on a LAN.

The server scans for ARP requests or replies that pass through it, then
aggregates them and formats them in a table in a web browser.

If you run this on multiple computers within a LAN, the servers will
discover each other and accessing any one of them will show the results
of all.

Uses:
 - socket.io
 - angular.js
 - express.js
 - node_pcap
 - node_mdns


Usage
-----

Install dependencies (zeroconf & pcap)

    sudo apt-get install libavahi-compat-libdnssd-dev
    sudo apt-get install libpcap-dev

Install arp-inspector

    git clone git@github.com:jordwest/arp-inspector.git
    cd arp-inspector/client/lib
    bower install
    cd ../../
    npm install
    grunt build
    sudo node server/server.js

Then navigate to [http://localhost:8080/](http://localhost:8080/) in a web browser
