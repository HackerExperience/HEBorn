index = require('./app.js');
app = index.app;

if (app.version === "dev") {
  app.ports.windowLoaded.send(0);
} else {
  window.onload = function() {
    app.ports.windowLoaded.send(0);
  }
}
