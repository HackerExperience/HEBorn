index = require('./index.js');
app = index.app;
var map = {};
app.ports.mapInit.subscribe(function(id) {
	var zeta;
	zeta = function(e) {
		document.removeEventListener("DOMNodeInserted", zeta);
		tmap = L.map(id).setView([38.487, -75.641], 10);
		L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
		    maxZoom: 18
		}).addTo(tmap);
		tmap.on('click', function onMapClick(e) {
			var ll = e.latlng;
			app.ports.mapClick.send({"lat":ll.lat, "lng":ll.lng});
		});
		map[id] = tmap;
	}
	document.addEventListener("DOMNodeInserted", zeta);
});
app.ports.mapCenter.subscribe(function(id, lat, long, zoom) {
    map[id].setView([lat, long], zoom);
});
