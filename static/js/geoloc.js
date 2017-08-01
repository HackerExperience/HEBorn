index = require('./app.js');
app = index.app;

app.ports.geoReq.subscribe(function(reqid) {
	var watchID = null;
	watchID = navigator.geolocation.watchPosition(function(pos) {
			app.ports.geoResp.send({
                          'reqid': reqid,
				'lat': pos.coords.latitude,
				'lng': pos.coords.longitude
			});
			navigator.geolocation.clearWatch(watchID);
		},
		null, {enableHighAccuracy:true}
	);
});
