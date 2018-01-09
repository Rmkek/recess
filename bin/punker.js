#!/bin/bash
var path;

path = require('path');

(async function() {
  var main, punk;
  main = path.resolve(__dirname, '../lib/cli/main.js');
  punk = require(main);
  return (await punk(process.argv));
})();
