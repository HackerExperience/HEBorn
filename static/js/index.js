require('../css/index.css');
require('../css/fonts.css');
var Elm = require('../../src/Main');
var node = document.getElementById('app');
var app = Elm.Main.embed(node, {
  'seed': Math.floor(Math.random() * 0x0FFFFFFF),
  'apiHttpUrl': process.env.HEBORN_API_HTTP_URL || "https://localhost:4000/v1",
  'apiWsUrl': process.env.HEBORN_API_WEBSOCKET_URL || "wss://localhost:4000/websocket",
  'version': process.env.HEBORN_VERSION || "dev"
});
app.ports.setCurrentTime.subscribe(function(id, time) {
    var audio = document.getElementById(id);
    audio.currentTime = time;
});
app.ports.play.subscribe(function(id) {
    var audio = document.getElementById(id);
    audio.play();
});
app.ports.pause.subscribe(function(id) {
    var audio = document.getElementById(id);
    audio.pause();
});