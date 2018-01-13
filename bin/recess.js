#!/usr/bin/env node
var path;

path = require('path');

(async function() {
  var main, recess;
  main = path.resolve(__dirname, '../lib/cli/main.js');
  recess = require(main);
  return (await recess(process.argv));
})();
