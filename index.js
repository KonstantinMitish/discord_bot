require('coffeescript/register');
var coffee = require('coffeescript');
var fs = require('fs');
eval(coffee.compile(fs.readFileSync("index.coffee").toString()));
