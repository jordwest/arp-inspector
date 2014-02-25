var express = require('express');

var app = express();
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);
var ioclient = require('socket.io-client');
var http = require('http');

var PORT = 7871;

var Crypto = require('crypto');

var serverId = null;

app.use(express.static(__dirname + '/../.build'));

server.listen(PORT);

var Pcap = require('pcap');

var ethInterface = process.argv[2];
console.log("Using interface " + ethInterface);
var pcap_session = Pcap.createSession(ethInterface, 'ether proto \\arp');

var devices = {};

var addDevice = function(hwaddr, ip)
{
    // Ignore broadcast addresses
    if(hwaddr === '00:00:00:00:00:00')
    {
        return;
    }

    if(!(hwaddr in devices))
    {
        devices[hwaddr] = {mac: hwaddr, ip: ip, count: 0};

        // Get vendor
        http.get("http://api.macvendors.com/" + hwaddr, function(res){
            devices[hwaddr].vendor = res.body;
        });
    }
    devices[hwaddr].count++;
    devices[hwaddr].ip = ip;
    devices[hwaddr].lastSeen = new Date();
}

pcap_session.on('packet', function(raw){
    console.log("Packet coming in");
    var packet = Pcap.decode.packet(raw);
    if(packet.link && packet.link.arp)
    {
        var arp = packet.link.arp;
        addDevice(arp.sender_ha, arp.sender_pa);
        addDevice(arp.target_ha, arp.target_pa);
    }
    io.sockets.emit('devices', devices);
});

io.sockets.on('connection', function(socket){
    socket.emit('devices', devices);
});

