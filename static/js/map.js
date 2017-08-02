index = require('./app.js');
app = index.app;
var map = {};
app.ports.mapInit.subscribe(function(id) {
  var zeta;
  zeta = function(e) {
    document.removeEventListener('DOMNodeInserted', zeta);
    tmap = L.map(id).setView([-21.1, -45.54568], 16);
    tmap.invalidateSize();
    L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
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
app.ports.mapCenter.subscribe(function(data) {
  var id=data[0],
    lat=data[1],
    lng=data[2],
    zoom=data[3],
    m = map[id];
  if(m != undefined) {
    m.invalidateSize();
    m.setView([lat, lng], zoom);
  }
});
