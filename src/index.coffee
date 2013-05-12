
m = require 'module'
fs = require 'fs'
vm = require 'vm'
path = require 'path'
Runner = require './runner'

filename = path.resolve __dirname, 'spectacular.js'
src = fs.readFileSync filename
vm.runInThisContext src, filename

filename = path.resolve __dirname, 'matchers.js'
src = fs.readFileSync filename
vm.runInThisContext src, filename

exports.run = (options) -> new Runner(rootExampleGroup, options).run()

