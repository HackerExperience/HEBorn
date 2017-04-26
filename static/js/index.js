var Elm = require('../../src/Main');
var node = document.getElementById('app');
Elm.Main.embed(node, {
  'seed': Math.floor(Math.random() * 0x0FFFFFFF),
  'apiHttpUrl': process.env.HEBORN_API_HTTP_URL || "https://localhost:4000/v1",
  'apiWsUrl': process.env.HEBORN_API_WEBSOCKET_URL || "wss://localhost:4000"
});
