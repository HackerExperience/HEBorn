var app = index.app;

var maps = {};
var address = '//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'

function send(data) {
  app.ports.leafletSub.send(data);
}

function withElement(id, cb) {
  if (document.getElementById(id)) return cb();

  var listener = function () {
    if (!document.getElementById(id)) return;
    document.removeEventListener('DOMNodeInserted', listener);
    cb();
  };

  document.addEventListener('DOMNodeInserted', listener);
}

function init (cmd) {
  var id = cmd.id;

  withElement(id, function () {
    var map = L.map(id, {zoomSnap: 0.25}).setView([-21.1, -45.54568], 16);
    var projections = {test: L.latLng(-23.9949, -46.2569)};
    var previousCenter = map.latLngToLayerPoint(map.getCenter());

    L.tileLayer(address, {maxZoom: 18}).addTo(map);
    maps[id] = [map, projections];
    map.invalidateSize();

    // click event
    function onMapClick(e) {
      // send click event
      send({
        'id': id,
        'msg': 'clicked',
        'lat': e.latlng.lat,
        'lng': e.latlng.lng
        // TODO: maybe sending pixel coordinates would also be interesting
      });
    }
    // move or zoomanim events
    function onMapMove() {
      var size = map.getSize();
      var center = map.latLngToLayerPoint(map.getCenter());

      // semd diff
      send({
        'id': id,
        'msg': 'moved',
        'x': previousCenter.x - center.x,
        'y': previousCenter.y - center.y
      });

      previousCenter = center

      // send changed projections
      Object.keys(projections).forEach(name => {
        if (!projections[name]) return;
        var offset = map.latLngToLayerPoint(projections[name]);

        send({
          'id': id,
          'msg': 'projected',
          'name': name,
          'x': (size.x / 2) - (center.x - offset.x),
          'y': (size.y / 2) - (center.y - offset.y)
        });
      });
    }

    map.on('click', onMapClick);
    map.on('move', onMapMove);
    map.on('zoomanim', onMapMove);
  });
}

function insertProjection(cmd) {
  var id = cmd.id;
  var name = cmd.name;
  var projections = maps[id] && maps[id][1];
  if (!projections) return;

  projections[name] = L.latLng(cmd.lat, cmd.lng);
}

function removeProjection(cmd) {
  var id = cmd.id;
  var name = cmd.name;
  var projections = maps[id] && maps[id][1];
  if (!projections) return;

  delete projections[name];
}

function center(cmd) {
  var id = cmd.id
  var map = maps[id] && maps[id][0];
  if (!map) return;

  map.invalidateSize();
  map.setView([cmd.lat, cmd.lng], cmd.zoom);
}

app.ports.leafletCmd.subscribe(function leafletCmd(cmd) {
  switch (cmd.msg) {
    case 'init':
      init(cmd);
      break;

    case 'insertProjection':
      insertProjection(cmd);
      break;

    case 'removeProjection':
      removeProjection(cmd);
      break;

    case 'center':
      center(cmd);
      break;

    default:
      console.log(
        'Leaflet communication error: command "'
        + cmd.msg
        + '" does not exist.'
      );
  }
});
