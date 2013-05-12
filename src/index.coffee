
m = require 'module'
fs = require 'fs'
vm = require 'vm'
path = require 'path'
Runner = require './runner'

['factories', 'spectacular'].forEach (file) ->
  filename = path.resolve __dirname, "#{file}.js"
  src = fs.readFileSync filename
  vm.runInThisContext src, filename

matchers = require './matchers'
global[k] = v for k,v of matchers

exports.run = (options) -> new Runner(rootExampleGroup, options).run()

