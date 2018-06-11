var app = index.app;

var maps = {};
var address = "//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";

function send(data) {
  app.ports.leafletSub.send(data);
}

function withElement(id, cb) {
  if (document.getElementById(id)) return cb();

  var listener = function() {
    if (!document.getElementById(id)) return;
    document.removeEventListener("DOMNodeInserted", listener);
    cb();
  };

  document.addEventListener("DOMNodeInserted", listener);
}

// creates a new map (cmd)
function init(cmd) {
  var id = cmd.id;

  withElement(id, function() {
    var map = L.map(id, { zoomSnap: 0.25 }).setView([-21.1, -45.54568], 16);
    var projections = { test: L.latLng(-23.9949, -46.2569) };
    var shapes = {};
    var previousCenter = map.latLngToLayerPoint(map.getCenter());

    L.tileLayer(address, { maxZoom: 18 }).addTo(map);
    maps[id] = [map, projections, shapes];
    map.invalidateSize();

    // click event
    function onMapClick(e) {
      // send click event
      send({
        id: id,
        msg: "clicked",
        lat: e.latlng.lat,
        lng: e.latlng.lng
        // TODO: maybe sending pixel coordinates would also be interesting
      });
    }
    // move or zoomanim events
    function onMapMove() {
      var size = map.getSize();
      var center = map.latLngToLayerPoint(map.getCenter());

      // semd diff
      send({
        id: id,
        msg: "moved",
        x: previousCenter.x - center.x,
        y: previousCenter.y - center.y
      });

      previousCenter = center;

      // send changed projections
      Object.keys(projections).forEach(name => {
        if (!projections[name]) return;
        var offset = map.latLngToLayerPoint(projections[name]);

        send({
          id: id,
          msg: "projected",
          name: name,
          x: size.x / 2 - (center.x - offset.x),
          y: size.y / 2 - (center.y - offset.y)
        });
      });
    }

    map.on("click", onMapClick);
    map.on("move", onMapMove);
    map.on("zoomanim", onMapMove);
  });
}

// inserts projection tracker (cmd)
function insertProjection(cmd) {
  var id = cmd.id;
  var name = cmd.name;
  var projections = maps[id] && maps[id][1];
  if (!projections) return;

  projections[name] = L.latLng(cmd.lat, cmd.lng);
}

// removes projection tracker (cmd)
function removeProjection(cmd) {
  var id = cmd.id;
  var name = cmd.name;
  var projections = maps[id] && maps[id][1];
  if (!projections) return;

  delete projections[name];
}

// creates a shape style object from shape object
function shapeStyle(shape) {
  var opts = {};

  if (shape.color !== undefined) opts.color = shape.color;
  if (shape.opacity !== undefined) opts.opacity = shape.opacity;
  if (shape.fill !== undefined) opts.fill = shape.fill;
  if (shape.fillColor !== undefined) opts.fillColor = shape.fillColor;
  if (shape.fillOpacity !== undefined) opts.fillOpacity = shape.fillOpacity;
  if (shape.stroke !== undefined) opts.stroke = shape.stroke;
  if (shape.weight !== undefined) opts.weight = shape.weight;

  return opts;
}

// inserts antPolyline style properties from shape object
function antPolylineStyle(opts, shape) {
  if (shape.pulseColor) opts.pulseColor = shape.pulseColor;
  if (shape.delay) opts.delay = shape.delay;
  if (shape.dashArray) opts.dashArray = shape.dashArray;
  return opts;
}

// adds shape events
function shapeEvents(cmd, shape) {
  shape.on('click', function () {
    send({
      id: cmd.id,
      msg: "clickedShape",
      name: cmd.name
    });
  })


  shape.on('mouseover', function () {
    send({
      id: cmd.id,
      msg: "hoveredShape",
      name: cmd.name,
      over: true
    });
  })

  shape.on('mouseout', function () {
    send({
      id: cmd.id,
      msg: "hoveredShape",
      name: cmd.name,
      over: false
    });
  })
}

// creates a new shape
function insertShape(cmd) {
  var map = maps[cmd.id] && maps[cmd.id][0];
  var shapes = maps[cmd.id] && maps[cmd.id][2];

  if (!map) return;
  if (!shapes) return;

  var opts = shapeStyle(cmd.shape);

  if (cmd.shape.type === "polyline") {
    var shape = L.polyline(cmd.shape.lines, opts);
    shapes[cmd.name] = { type: "polyline", shape: shape };
    shapeEvents(cmd, shape);
    shape.addTo(map);
  } else if (cmd.shape.type === "antPolyline") {
    var shape = L.polyline.antPath(
      cmd.shape.lines,
      antPolylineStyle(opts, cmd.shape)
    );
    shapes[cmd.name] = { type: "antPolyline", shape: shape };
    shapeEvents(cmd, shape);
    shape.addTo(map);
  } else if (cmd.shape.type === "circle") {
    opts.radius = cmd.shape.radius;

    var shape = L.circle(cmd.shape.position, opts);
    shapes[cmd.name] = { type: "circle", shape: shape };
    shapeEvents(cmd, shape);
    shape.addTo(map);
  }
}

// updates existing shape
function updateShape(cmd) {
  var shapes = maps[cmd.id] && maps[cmd.id][2];

  if (!shapes) return;

  if (shapes[cmd.name]) {
    var shape = shapes[cmd.name].shape;
    var opts = shapeStyle(cmd.shape);

    if (cmd.shape.type === "polyline") {
      if (cmd.shape.lines) shape.setLatLngs(cmd.shape.lines);
      shape.setStyle(opts);
    } else if (cmd.shape.type === "antPolyline") {
      if (cmd.shape.lines) shape.setLatLngs(cmd.shape.lines);
      shape.setStyle(antPolylineStyle(opts));
    } else if (cmd.shape.type === "circle") {
      if (cmd.shape.position) shape.setLatLng(cmd.shape.position);
      if (cmd.shape.radius) shape.setRadius(cmd.shape.radius);
      shape.setStyle(opts);
    }
  }
}

// upserts shape (cmd)
function setShape(cmd) {
  var shapes = maps[cmd.id] && maps[cmd.id][2];

  if (!shapes) return;

  if (shapes[cmd.name] !== undefined) {
    if (shapes[cmd.name].type !== cmd.shape.type) {
      removeShape(cmd);
      insertShape(cmd);
    } else {
      updateShape(cmd);
    }
  } else {
    insertShape(cmd);
  }
}

// removes shape (cmd)
function removeShape(cmd) {
  var map = maps[cmd.id] && maps[cmd.id][0];
  var shapes = maps[cmd.id] && maps[cmd.id][2];

  if (!map) return;
  if (!shapes) return;

  if (shapes[cmd.name]) {
    map.removeLayer(shapes[cmd.name].shape);
    delete shapes[cmd.name];
  }
}

// centralizes the map (cmd)
function center(cmd) {
  var map = maps[cmd.id] && maps[cmd.id][0];
  if (!map) return;

  map.invalidateSize();
  map.setView([cmd.lat, cmd.lng], cmd.zoom);
}

app.ports.leafletCmd.subscribe(function leafletCmd(cmd) {
  switch (cmd.msg) {
    case "init":
      init(cmd);
      break;

    case "insertProjection":
      insertProjection(cmd);
      break;

    case "removeProjection":
      removeProjection(cmd);
      break;

    case "setShape":
      setShape(cmd);
      break;

    case "removeShape":
      removeShape(cmd);
      break;

    case "center":
      center(cmd);
      break;

    default:
      console.log(
        'Leaflet communication error: command "' + cmd.msg + '" does not exist.'
      );
  }
});
