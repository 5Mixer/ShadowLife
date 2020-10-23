// Simple (websocket/socket) server for the game
// Static hosting is dealt with separetly (netlify, for CDN/SSL)

const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

var worlds = {}

function generateID() {
    var dict = "abcdefghijklmnopqrstuvwxyz";
    var id = "";
    for (i = 0; i < 20; i++) {
        id += dict[Math.floor(Math.random() * dict.length)];
    }
    return id;
}

wss.on('connection', function connection(ws) {
    ws.world = ""
    
    ws.on('message', function incoming(message) {

        if (typeof message != "string"){
            // World (bytes) message
            worlds[ws.world] = message;

            wss.clients.forEach(function each(client) {
                if (client.readyState === WebSocket.OPEN && client !== wss && client.world == ws.world) {
                    client.send(message);
                }
            });

        }else {
            console.log('received: %s', message);
            if(message == "!worldRequest") {
                // Allocate a new world
                ws.world = "#" + "a";//generateID();
                var attempts = 0;
                
                // Generate id's without clashes in the first 5 chars
                var good = false;
                while (!good && attempts < 20) {
                    good = true;
                    for (var i = 0; i < worlds.length; i++) {
                        if (worlds[i].substr(0, 5) == ws.world.substr(0, 5)) {
                            good = false;
                            ws.world = generateID();
                            attempts++;
                            break;
                        }
                    }
                }
                
                ws.send("!worldAllocated:" + ws.world);
            }
            if(message == "!updateRequest") {
                if (worlds[ws.world] != undefined)
                    ws.send(worlds[ws.world])
            }
            if (message.indexOf("!joinWorld:") == 0) {
                ws.world = message.split(":")[1];
                if (worlds[ws.world] != undefined)
                    ws.send(worlds[ws.world])
            }
        }
        
    });
    
    ws.send('something');
});