index = require('./app.js');
app = index.app;
app.ports.setCurrentTime.subscribe(function(data) {
  var id = data[0],
    time = data[1];
  var audio = document.getElementById(id);
  audio.currentTime = time;
});
app.ports.play.subscribe(function(id) {
  var audio = document.getElementById(id);
  audio.play();
});
app.ports.pause.subscribe(function(id) {
  var audio = document.getElementById(id);
  audio.pause();
});
