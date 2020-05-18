#!/usr/bin/env node
let WebSocketServer = require('websocket').server;
let http = require('http');
let fs = require('fs');
let path = require('path');

let server = http.createServer(function(request, response) {
    console.log((new Date()) + ' Received request for ' + request.url);
    let filePath = './client' + request.url;
    if (request.url == '/')
        filePath += '/index.html';

    let extname = path.extname(filePath);
    let contentType = 'text/html';
    switch (extname) {
        case '.js':
            contentType = 'text/javascript';
            break;
        case '.css':
            contentType = 'text/css';
            break;
        case '.json':
            contentType = 'application/json';
            break;
        case '.png':
            contentType = 'image/png';
            break;
        case '.jpg':
            contentType = 'image/jpg';
            break;
    }

    fs.readFile(filePath, function(error, content) {
        if (error) {
            if(error.code == 'ENOENT'){
                response.writeHead(404);
                response.end('Error: 404 - Could not find anything here...');
            }
            else {
                response.writeHead(500);
                response.end('Something went wrong...');
                response.end();
            }
        }
        else {
            response.writeHead(200, { 'Content-Type': contentType });
            response.end(content, 'utf-8');
        }
    });
});


server.listen(80, function() {
    console.log((new Date()) + ' Server is listening on port 80');
});

wsServer = new WebSocketServer({
    httpServer: server,
    // You should not use autoAcceptConnections for production
    // applications, as it defeats all standard cross-origin protection
    // facilities built into the protocol and the browser.  You should
    // *always* verify the connection's origin and decide whether or not
    // to accept it.
    autoAcceptConnections: false
});

function originIsAllowed(origin) {
    // put logic here to detect whether the specified origin is allowed.
    return true;
}


let socketConnections = {};

let Elm = require('./backend.js');
let elmApp = Elm.Elm.Backend.init();
elmApp.ports.sendMessage.subscribe(function(data) {
    playerNumber = data[0];
    message = data[1];
    // @todo: this still needs some proper error handling in case data is not a list of two items
    switch (playerNumber) {
        case '1':
            socketConnections['p1'].sendUTF(message);
            break;
        case '2':
            socketConnections['p2'].sendUTF(message);
            break;
        case 'all':
            for (let key in socketConnections) {
                socketConnections[key].sendUTF(message);
            }
            break;
        default:
            console.log("Error while parsing message from Elm: format is incorrect, could not find p1, p2 or all "+data);
    }
});

wsServer.on('request', function(request) {
    if (!originIsAllowed(request.origin)) {
        // Make sure we only accept requests from an allowed origin
        request.reject();
        console.log((new Date()) + ' Connection from origin ' + request.origin + ' rejected.');
        return;
    }

    let connection = request.accept('echo-protocol', request.origin);

    if (!socketConnections.hasOwnProperty('p1')) {
        connection.playerNumber = '1';
        socketConnections.p1 = connection;
    } else if (!socketConnections.hasOwnProperty('p2')) {
        socketConnections.p2 = connection;
        connection.playerNumber = '2';
    } else {
        connection.close();
        return;
    }

    console.log((new Date()) + ' Connection accepted: ' + connection.playerNumber);
    connection.on('message', function(message) {
        if (message.type === 'utf8') {
            string = injectPlayerNumber(message.utf8Data, connection.playerNumber);
            elmApp.ports.messageReceiver.send(string);
        }
        // else if (message.type === 'binary') {
        //     console.log('Received Binary Message of ' + message.binaryData.length + ' bytes');
        //     connection.sendBytes(message.binaryData);
        // }
    });
    connection.on('close', function(reasonCode, description) {
        console.log((new Date()) + ' Peer ' + connection.remoteAddress + ' disconnected.');
    });
});

function injectPlayerNumber(data, playerNumber) {
    // @todo: cleanup, ugly way to insert into json, don't feel like to parse and stringify again
    if (data.length > 2) {
        return data.slice(0, -1) + ",\"player\":" + playerNumber + "}";
    } else {
        return data;
    }
}
