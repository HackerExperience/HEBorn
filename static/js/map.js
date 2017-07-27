index = require('./index.js');
app = index.app;
var map = {};
app.ports.mapInit.subscribe(function(id) {
	var zeta;
	zeta = function(e) {
		document.removeEventListener('DOMNodeInserted', zeta);
		tmap = L.map(id).setView([38.487, -75.641], 10);
		tmap.invalidateSize();
		L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
		    maxZoom: 18
		}).addTo(tmap);
		tmap.on('click', function onMapClick(e) {
			var ll = e.latlng;
			app.ports.mapClick.send({
				'req':id,
				'lat':ll.lat,
				'lng':ll.lng
			});
		});
		map[id] = tmap;
	}
	document.addEventListener('DOMNodeInserted', zeta);
});
app.ports.mapCenter.subscribe(function([id,lat,lng,zoom]) {
	var m = map[id];
    if(m != undefined) {
    	m.invalidateSize();
    	m.setView([lat, lng], zoom);
    }
});
