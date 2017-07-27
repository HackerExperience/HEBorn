index = require('./index.js');
app = index.app;
var watchID = null;
poswatcher = function(pos) {
	app.ports.geoResp.send({
		'lat': pos.coords.latitude,
		'lng': pos.coords.longitude
	});
};
posfailed = function() {};
app.ports.geoReq.subscribe(function(dummy) {
	if(watchID == null)
		 watchID = navigator.geolocation.watchPosition(poswatcher, posfailed, {enableHighAccuracy:true});
});
app.ports.geoStop.subscribe(function(dummy) {
	if(watchID == null)
		 navigator.geolocation.clearWatch(watchID);
	watchID = null;
});
