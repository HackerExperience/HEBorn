var app = index.app

function send(data) {
  app.ports.leafletSub.send(data);
}

function withElement(id, cb) {
  if (document.getElementById(id)) return cb();

  var listener = function () {
    if (!document.getElementById(id)) return;
    document.removeEventListener('DOMNodeInserted', listener);
    cb();
  }

  document.addEventListener('DOMNodeInserted', listener);
}

var maps = {};

app.ports.leafletCmd.subscribe(function (cmd) {
  switch (cmd.msg) {
    case 'init':
      var id = cmd.id;
      withElement(id, function () {
        var map = L.map(id, {zoomSnap: 0.25}).setView([-21.1, -45.54568], 16);

        map.invalidateSize();

        L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 18
        }).addTo(map);

        map.on('click', function onMapClick(event) {
          send({
            'id': id,
            'msg': 'clicked',
            'lat': event.latlng.lat,
            'lng': event.latlng.lng
          });
        });

        maps[id] = map;
      })
      break;

    case 'center':
      var id = cmd.id, lat = cmd.lat, lng = cmd.lng, zoom = cmd.zoom;
      var map = maps[id]
      if (!map) return;
      map.invalidateSize()
      map.setView([lat, lng], zoom);
      break;

    default:
      console.log(
        'Leaflet communication error: command "'
        + cmd.msg
        + '" does not exist.'
      );
  }
});
