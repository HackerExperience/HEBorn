index = require('./app.js');
app = index.app;
window.onload = function() {
  app.ports.windowLoaded.send(0);
}
