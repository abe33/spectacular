
m = require 'module'
fs = require 'fs'
vm = require 'vm'
Q = require 'q'
path = require 'path'
walk = require 'walkdir'
Runner = require './runner'

loadMatchers = (options) ->
  defer = Q.defer()

  if options.noMatchers
    defer.resolve()
  else
    emitter = walk options.matchersRoot
    emitter.on 'file', (path, stat) ->
      matchers = require path
      global[k] = v for k,v of matchers
    emitter.on 'end', -> defer.resolve()

  defer.promise

exports.run = (options) ->
  ['factories', 'spectacular'].forEach (file) ->
    filename = path.resolve __dirname, "#{file}.js"
    src = fs.readFileSync filename
    vm.runInThisContext src, filename

  matchers = require './matchers'
  global[k] = v for k,v of matchers

  loadMatchers(options).then ->
    new Runner(rootExampleGroup, options).run()

