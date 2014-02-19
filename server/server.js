var express = require('express');

var app = express();
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);
var ioclient = require('socket.io-client');

var PORT = 7871;

var mdns = require('mdns');
var Crypto = require('crypto');

var serverId = null;

Crypto.pseudoRandomBytes(16, function(ex, bytes){
    serverId = bytes.toString('hex');
    // Advertise our service to others
    var ad = mdns.createAdvertisement(mdns.tcp('arpinspector'), PORT, {txtRecord: {id: serverId}});
    ad.start();
});

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
    }
    devices[hwaddr].count++;
    devices[hwaddr].ip = ip;
    devices[hwaddr].lastSeen = new Date();
}

pcap_session.on('packet', function(raw){
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



var browser = mdns.createBrowser(mdns.tcp('arpinspector'));

var otherInspectors = [];

browser.on('serviceUp', function(service){
    console.log("New arp inspector found: ", service);
    if(service.txtRecord.id == serverId)
    {
        console.log("It's just ourselves....");
    }else{
        console.log("It's somebody else on the network");
        var remoteInspector = {};
        otherInspectors.push(remoteInspector);
        console.log(ioclient);
        var s = ioclient.connect('http://' + service.addresses[1] + ':' + service.port);
        s.on('connect', function(){
            s.on('devices', function(devices) {
                remoteInspector.devices = devices;
                io.sockets.emit('otherInspectors', otherInspectors);
            });
        });
    }
});
browser.on('serviceDown', function(service){
    console.log("Arp inspector down: ", service);
});
browser.start();
