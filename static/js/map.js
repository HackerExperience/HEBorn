index = require('./index.js');
app = index.app;
var map = {};
app.ports.mapInit.subscribe(function(id, lat, long, zoom) {
    map[id] = L.map(id).setView([lat, long], zoom);
    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        maxZoom: 18
    }).addTo(map[id]);
});
app.ports.mapCenter.subscribe(function(id, lat, long, zoom) {
    map[id].setView([lat, long], zoom);
});
