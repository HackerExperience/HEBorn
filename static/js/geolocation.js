var app = index.app

function send(data) {
  app.ports.geolocationSub.send(data);
}

var mk=process.env.HEBORN_MAPZEN_API_KEY || 'mapzen-0000000';

app.ports.geolocationCmd.subscribe(function(cmd) {
  switch (cmd.msg) {
    case 'coordinates':
      var watchID = null;

      watchID = navigator.geolocation.watchPosition(
        function(pos){
        send({
          'msg': 'coordinates',
          'id': cmd.id,
          'lat': pos.coords.latitude,
          'lng': pos.coords.longitude
        });
          navigator.geolocation.clearWatch(watchID);
        },
        null,
        {enableHighAccuracy:true}
      );

      break;
    case 'label':
      var lat = cmd.lat, lng = cmd.lng;
      var conn = new XMLHttpRequest();
      var url = '//search.mapzen.com/v1/reverse?api_key='+mk+'&point.lat='+lat+'&point.lon='+lng;

      conn.onreadystatechange = function() {
        if (conn.readyState == 4 && conn.status == 200) {
          var resp = JSON.parse(conn.responseText),
            feat = resp['features'][0]['properties'];

          send({
            'msg': 'label',
            'id': cmd.id,
            'label': feat['label']
          });

        }
      }

      conn.open('GET', url, true);
      conn.send();

      break;
    default:
      console.log(
        'Geolocation communication error: command "'
        + cmd.msg
        + '" does not exist.'
      );
  }
});
