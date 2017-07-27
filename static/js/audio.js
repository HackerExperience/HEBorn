index = require('./index.js');
app = index.app;
app.ports.setCurrentTime.subscribe(function([id, time]) {
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
