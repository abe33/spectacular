
m = require 'module'
fs = require 'fs'
vm = require 'vm'
Q = require 'q'
path = require 'path'
walk = require 'walkdir'
Runner = require './runner'

requireIntoGlobal = (file) ->
  matchers = require file
  global[k] = v for k,v of matchers

loadSpectacular = ->
  Q.fcall ->
    [ 'factories', 'extensions', 'mixins',
      'promises', 'examples', 'spectacular'
    ].forEach (file) ->
      filename = path.resolve __dirname, "#{file}.js"
      src = fs.readFileSync filename
      vm.runInThisContext src, filename

loadMatchers = (options) ->
  defer = Q.defer()

  if options.noMatchers
    defer.resolve()
  else
    emitter = walk options.matchersRoot
    emitter.on 'file', (path, stat) -> requireIntoGlobal path
    emitter.on 'end', -> defer.resolve()

  defer.promise

loadHelpers = (options) ->
  defer = Q.defer()

  if options.noHelpers
    defer.resolve()
  else
    emitter = walk options.helpersRoot
    emitter.on 'file', (path, stat) -> requireIntoGlobal path
    emitter.on 'end', -> defer.resolve()

  defer.promise

exports.run = (options) ->
  loadSpectacular()
  .then(-> requireIntoGlobal './matchers')
  .then(loadMatchers options)
  .then(loadHelpers options)
  .then ->
    new Runner(rootExampleGroup, options).run()

