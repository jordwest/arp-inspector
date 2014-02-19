var express = require('express');

var app = express();
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);

app.use(express.static(__dirname + '/../.build'));

server.listen(8080);

var Pcap = require('pcap');

var pcap_session = Pcap.createSession('en1', 'ether proto \\arp');

var devices = {};

var addDevice = function(hwaddr, ip)
{
    // Ignore broadcast addresses
    /*
    if(hwaddr === '00:00:00:00:00:00')
    {
        return;
    }
    */

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
