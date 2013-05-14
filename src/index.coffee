
m = require 'module'
fs = require 'fs'
vm = require 'vm'
Q = require 'q'
path = require 'path'
walk = require 'walkdir'
Runner = require './runner'

loadSpectacular = ->
  Q.fcall ->
    [ 'factories', 'extensions', 'mixins',
      'promises', 'examples', 'spectacular'
    ].forEach (file) ->
      filename = path.resolve __dirname, "#{file}.js"
      src = fs.readFileSync filename
      vm.runInThisContext src, filename

loadMatchersFile = (file) ->
  matchers = require file
  global[k] = v for k,v of matchers

loadMatchers = (options) ->
  defer = Q.defer()

  if options.noMatchers
    defer.resolve()
  else
    emitter = walk options.matchersRoot
    emitter.on 'file', (path, stat) -> loadMatchersFile path
    emitter.on 'end', -> defer.resolve()

  defer.promise

exports.run = (options) ->
  loadSpectacular()
  .then ->
    loadMatchersFile './matchers'
    loadMatchers(options)
  .then ->
    new Runner(rootExampleGroup, options).run()

