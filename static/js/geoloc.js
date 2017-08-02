index = require('./app.js');
app = index.app;

app.ports.geoLocReq.subscribe(function(reqid) {
  var watchID = null;
  watchID = navigator.geolocation.watchPosition(
    function(pos){
      app.ports.geoLocResp.send({
        'reqid': reqid,
        'lat': pos.coords.latitude,
        'lng': pos.coords.longitude
      });
      navigator.geolocation.clearWatch(watchID);
    },
    null,
    {enableHighAccuracy:true}
  );
});

var mk=process.env.HEBORN_MAPZEN_API_KEY || 'mapzen-0000000';

app.ports.geoRevReq.subscribe(function(data) {
  var reqid = data[0],
    lat = data[1],
    lng = data[2];
  var conn = new XMLHttpRequest();
  conn.onreadystatechange = function() {
        if (conn.readyState == 4 && conn.status == 200) {
            var resp = JSON.parse(conn.responseText),
              feat = resp['features'][0]['properties'];
            app.ports.geoRevResp.send({
              'reqid': reqid,
              'label': feat['label']
            });
        }
    }
  conn.open('GET', `//search.mapzen.com/v1/reverse?api_key=${mk}&point.lat=${lat}&point.lon=${lng}`, true);
  conn.send();
});
