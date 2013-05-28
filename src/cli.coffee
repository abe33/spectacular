
m = require 'module'
fs = require 'fs'
glob = require 'glob'
path = require 'path'
vm = require 'vm'
Q = require 'q'
walk = require 'walkdir'
util = require 'util'

requireIntoGlobal = (file) ->
  matchers = require file
  for k,v of matchers
    v._name = k if typeof v is 'function'
    global[k] = v

loadSpectacular = (options) ->
  Q.fcall ->
    filename = path.resolve __dirname, "spectacular.js"
    src = fs.readFileSync(filename).toString()
    vm.runInThisContext src, filename

    spectacular.env = new spectacular.Environment options
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

getReporter = (options) ->
  reporter = new spectacular.ConsoleReporter options
  reporter.on 'message', (event) -> util.print event.target
  reporter.on 'report', (event) -> util.print event.target
  reporter

loadFile = (options) ->
  cache = {}
  (file) ->
    Q.fcall ->
      return cache[file] if file of cache

      fileContent = fs.readFileSync(file).toString()
      if options.coffee and file.indexOf('.coffee') isnt -1
        {compile} = require 'coffee-script'
        fileContent = compile fileContent, bare: true
      fileContent

exports.run = (options) ->
  loadStartedAt = null
  loadEndedAt = null

  options.loadFile = loadFile(options)

  loadSpectacular(options)
  .then ->
    reporter = getReporter options
    spectacular.env.runner.on 'result', reporter.onResult
    spectacular.env.runner.on 'end', reporter.onEnd
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
      reporter = getReporter options
      console.log reporter.errorBadge "Spectacular failed"
      reporter.formatError(reason).then (msg) ->
        console.log msg
    else
      console.log reason.stack
