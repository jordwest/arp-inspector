var express = require('express');

var server = express();

server.use(express.static(__dirname + '/../.build'));

server.listen(8080);
