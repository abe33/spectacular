
m = require 'module'
fs = require 'fs'
glob = require 'glob'
path = require 'path'
vm = require 'vm'
Q = require 'q'
walk = require 'walkdir'
util = require 'util'
jsdom = require 'jsdom'
sourceMap = require 'source-map'

colorize= (str, color, options) ->
  if str? and options.colors and str[color] then str[color] else str

requireFile = (file, context) ->
  try
    require file
  catch err
    console.log file, err

exists = fs.exists or path.exists
existsSync = fs.existsSync or path.existsSync

loadSpectacular = (options) ->
  Q.fcall ->
    filename = path.resolve __dirname, "spectacular.js"
    src = fs.readFileSync(filename).toString()
    if options.verbose
      console.log "  #{colorize 'load spectacular', 'grey', options} #{filename}"
    vm.runInThisContext src, filename

    spectacular.env = new spectacular.Environment options
    spectacular.env.globalize()

handleEmitter = (emitter, defer) ->
  emitter.on 'end', -> defer.resolve()
  emitter.on 'error', (err) -> defer.reject(err)
  emitter.on 'fail', (err) -> defer.reject(err)

loadRequire = (path, options) ->
  defer = Q.defer()

  exists path, (exists) ->
    if exists
      emitter = walk path
      emitter.on 'file', (path, stat) ->
        if /(js|coffee)$/.test path
          if options.verbose
            console.log "  #{colorize 'require', 'grey', options} #{path}"
          requireFile path

      handleEmitter emitter, defer
    else
      defer.resolve()

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
  for p in paths
    if options.verbose
      console.log "  #{colorize 'load spec', 'grey', options} #{p}"
    require path.resolve('.', p)

  paths

getReporter = (options) ->
  reporter = spectacular.ConsoleReporter.getDefault options

  reporter.on 'message', (event) -> util.print event.target
  reporter.on 'report', (event) -> util.print event.target
  reporter

loadDOM = ->
  defer = Q.defer()
  jsdom.env
    html: '<html><head></head><body></body></html>'
    features:
      QuerySelector: true
    done: (err, window) ->
      return defer.reject(err) if err?
      defer.resolve window
  defer.promise

CliMethods = (options) ->
  fileCache = {}

  options.valueOutput = (value) -> colorize "#{value}", 'bold', spectacular.env.options
  options.isCoffeeScriptFile = (file) -> /\.coffee$/.test file
  options.hasSourceMap = (file) -> @isCoffeeScriptFile file
  options.loadFile = (file) ->
    Q.fcall ->
      unless existsSync file
        throw new Error "File doesn't exist: '#{file}'"

      return fileCache[file] if file of fileCache

      fileSource = fs.readFileSync(file).toString()
      if options.coffee and options.isCoffeeScriptFile file
        {compile} = require 'coffee-script'
        compileOptions = bare: true
        compileOptions.sourceMap = options.sourceMap
        fileContent = compile fileSource, compileOptions
        fileContent.source = fileSource if options.sourceMap

      fileCache[file] = fileContent or fileSource

  options.getOriginalSourceFor = (file, line, column) ->
    defer = Q.defer()
    @loadFile(file)
    .then (compiled) ->
      consumer = new sourceMap.SourceMapConsumer compiled.v3SourceMap
      {line, column} = consumer.originalPositionFor {line, column}
      defer.resolve {content: compiled.source, line, column}
    .fail (reason) -> defer.reject reason

    defer.promise

exports.run = (options) ->
  loadStartedAt = null
  loadEndedAt = null

  console.log colorize('  options','grey',options), options if options.verbose

  options.fixturesRoot = path.resolve options.fixturesRoot

  loadSpectacular(options)
  .then(loadDOM)
  .then (window) ->
    CliMethods(options)
    spectacular.global.window = window
    spectacular.global.document = window.document

    reporter = getReporter options
    spectacular.env.runner.on 'message', reporter.onMessage
    spectacular.env.runner.on 'result', reporter.onResult
    spectacular.env.runner.on 'end', reporter.onEnd

    Q.all(loadRequire p, options for p in options.requires)
  .then ->
    loadStartedAt = new Date()
  .then(globPaths options.globs)
  .then(loadSpecs options)
  .then (paths) ->
    loadEndedAt = new Date()
    options.paths = paths
    spectacular.env.runner.loadStartedAt = loadStartedAt
    spectacular.env.runner.loadEndedAt = loadEndedAt
    spectacular.env.run()
  .then (status) ->
    spectacular.env.unglobalize()
    status
  .fail (reason) ->
    handleError reason
