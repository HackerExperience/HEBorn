index = require('./app.js');
app = index.app;
app.ports.fetchFocused.subscribe(function() {
  var node = document.activeElement
  var result = node ?
    { 'type': node.nodeName
    , 'id' : node.id
    } : null;
  app.ports.focusedFetched.send(result);
});
