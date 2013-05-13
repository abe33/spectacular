
m = require 'module'
fs = require 'fs'
vm = require 'vm'
path = require 'path'
walk = require 'walkdir'
Runner = require './runner'


exports.run = (options) ->
  ['factories', 'spectacular'].forEach (file) ->
    filename = path.resolve __dirname, "#{file}.js"
    src = fs.readFileSync filename
    vm.runInThisContext src, filename

  matchers = require './matchers'
  global[k] = v for k,v of matchers

  unless options.noMatchers
    emitter = walk options.matchersRoot
    emitter.on 'file', (path, stat) ->
      matchers = require path
      global[k] = v for k,v of matchers

  new Runner(rootExampleGroup, options).run()

