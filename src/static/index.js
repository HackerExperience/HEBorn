var Elm = require('../elm/Main');
var node = document.getElementById('app');
Elm.Main.embed(node, {
  'seed': Math.floor(Math.random() * 0x0FFFFFFF)
})
