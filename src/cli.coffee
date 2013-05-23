
m = require 'module'
fs = require 'fs'
glob = require 'glob'
path = require 'path'
vm = require 'vm'
Q = require 'q'
utils = require './utils'
walk = require 'walkdir'
{ConsoleReporter} = require './console_reporter'

requireIntoGlobal = (file) ->
  matchers = require file
  for k,v of matchers
    v._name = k if typeof v is 'function'
    global[k] = v

loadSpectacular = (options) ->
  Q.fcall(->
    filename = path.resolve __dirname, "spectacular.js"
    src = fs.readFileSync(filename).toString()
    vm.runInThisContext src, filename

    spectacular.env = new spectacular.Environment(
      ConsoleReporter, options
    )
  ).then ->
    spectacular.env.load()

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

globPath = (path) ->
  defer = Q.defer()
  glob path, (err, res) ->
    return defer.reject err if err
    defer.resolve res

  defer.promise

globPaths= (globs) -> ->
  Q.all(globPath p for p in globs).then (results) =>
    paths = []
    results.forEach (a) -> paths = paths.concat a
    paths

loadSpecs = (options) -> (paths) ->
  console.log "Load specs: #{paths}\n" if options.verbose
  require path.resolve('.', p) for p in paths
  paths

exports.run = (options) ->
  loadStartedAt = null
  loadEndedAt = null

  loadSpectacular(options)
  .then(-> requireIntoGlobal './matchers')
  .then(loadMatchers options)
  .then(loadHelpers options)
  .then ->
    loadStartedAt = new Date()
  .then(globPaths options.globs)
  .then(loadSpecs options)
  .then (paths) ->
    loadEndedAt = new Date()
    spectacular.env.runner.loadStartedAt = loadStartedAt
    spectacular.env.runner.loadEndedAt = loadEndedAt
    spectacular.env.runner.paths = paths
    spectacular.env.run()
  .fail (reason) ->
    if spectacular.env?
      console.log spectacular.env.formatter.errorBadge "Spectacular failed"
      console.log spectacular.env.formatter.formatError reason
    else
      console.log reason.stack
