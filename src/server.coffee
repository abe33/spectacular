fs = require 'fs'
Q = require 'q'
glob = require 'glob'
path = require 'path'
express = require 'express'
walk = require 'walkdir'
util = require 'util'
{spawn} = require 'child_process'

exists = fs.exists or path.exists

SPECTACULAR_ROOT = path.resolve __dirname, '..'

colorize = null

findrequire = (p, options) ->
  defer = Q.defer()
  res = []

  exists p, (exist) ->
    if exist
      emitter = walk p
      emitter.on 'file', (p, stat) -> res.push path.relative '.', p
      emitter.on 'end', -> defer.resolve res
    else
      defer.resolve([])

  defer.promise

globPath = (p) ->
  defer = Q.defer()
  glob p, (err, res) ->
    return defer.reject err if err
    defer.resolve res

  defer.promise

globPaths= (globs) ->
  Q.all(globPath p for p in globs).then (results) =>
    paths = []
    results.forEach (a) -> paths = paths.concat a
    paths

scriptNode = (path) ->
  "<script type='text/javascript' src='#{path}'></script>"

generateSpecRunner = (options) ->
  console.log "  #{colorize 'options', 'grey'} #{util.inspect options}" if options.verbose
  paths = [
    'assets/js/spectacular.js'
    'assets/js/browser_reporter.js'
  ]
  Q.all(findrequire p, options for p in options.requires)
  .then (requires) ->
    for collection in requires
      for f in collection
        if /(js|coffee)$/.test f
          paths.push f
          console.log "  #{colorize 'requires', 'grey'} #{f}" if options.verbose

    globPaths options.globs
  .then (specs) ->
    console.log "  #{colorize 'spec', 'grey'} #{f}" for f in specs if options.verbose
    paths = paths.concat specs
    uniq = []
    uniq.push v for v in paths when v not in uniq
    paths = uniq
  .then ->
    globPaths options.sources
  .then (sources) ->
    console.log "  #{colorize 'source', 'grey'} #{f}" for f in sources if options.verbose

    sourceMapMethods = """
    spectacular.options.hasSourceMap = function(file) {
      return /\\.coffee$/.test(file);
    };
    spectacular.options.getSourceURLFor = function(file) {
      return file.replace('.coffee', '.coffee.src')
    };
    spectacular.options.getSourceMapURLFor = function(file) {
      return file.replace('.coffee', '.map')
    };
    """

    """
      <!doctype html>
      <html>
        <head>
          <script>
            window.spectacular = {
              options: #{util.inspect options},
              paths: #{util.inspect paths[2..]}
            };
            #{ if options.sourceMap then sourceMapMethods else '' }
          </script>
          <link href='http://fonts.googleapis.com/css?family=Roboto:400,100,300' rel='stylesheet' type='text/css'>
          <link rel="stylesheet" href="assets/css/spectacular.css"/>
          <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/font-awesome/3.0.2/css/font-awesome.min.css"/>
          #{ if options.sourceMap then scriptNode 'vendor/source-map.js' else '' }
          #{(scriptNode p for p in sources).join '\n'}
          #{(scriptNode p for p in paths).join '\n'}
        </head>
        <body></body>
      </html>
    """

exports.run = (options) ->
  colorize = (str, color) -> if options.colors then str[color] else str
  defer = Q.defer()
  app = express()

  app.get '/', (req, res) ->
    generateSpecRunner(options).then (html) ->
      console.log "  #{colorize '200', 'green'} #{colorize 'GET', 'cyan'} /"
      res.send html

  app.use '/assets/js', express.static path.resolve SPECTACULAR_ROOT, 'lib'
  app.use '/vendor', express.static path.resolve SPECTACULAR_ROOT, 'vendor'
  app.use '/assets/css', express.static path.resolve SPECTACULAR_ROOT, 'css'
  app.use '/', (req, res, next) ->

    if /\.coffee$/.test(req.url) and options.coffee
      content = fs.readFileSync(path.resolve ".#{req.url}").toString()
      {compile} = require 'coffee-script'
      content = compile content

    else if /\.coffee\.src$/.test(req.url) and options.coffee
      content = fs.readFileSync(path.resolve ".#{req.url.replace '.coffee.src', '.coffee'}").toString()

    else if /\.map$/.test(req.url) and options.coffee
      content = fs.readFileSync(path.resolve ".#{req.url.replace '.map', '.coffee'}").toString()
      {compile} = require 'coffee-script'
      compiled = compile content, sourceMap: true
      content = compiled.v3SourceMap

    else
      content = fs.readFileSync(path.resolve ".#{req.url}").toString()

    console.log "  #{colorize '200', 'green'} #{colorize 'GET', 'cyan'} #{req.url}"
    res.send content

  port = process.env.PORT or 5000
  app.listen port
  console.log "  server listening on port #{port.toString().cyan}"

  if options.phantomjs
    console.log "  running tests on phantomjs"
    phantom = spawn options.phantomjsExecutable, ['./lib/spectacular_phantomjs.js', port]
    phantom.stdout.on 'data', (data) -> util.print data.toString()
    phantom.stderr.on 'data', (data) -> util.print data.toString()
    phantom.on 'exit', (status) ->
      process.exit status

  if options.slimerjs
    console.log "  running tests on slimerjs"
    phantom = spawn options.slimerjsExecutable, ['./src/spectacular_slimerjs.coffee', port]
    phantom.stdout.on 'data', (data) -> util.print data.toString()
    phantom.stderr.on 'data', (data) -> util.print data.toString()
    phantom.on 'exit', (status) ->
      process.exit status

  defer.promise

