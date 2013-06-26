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

findMatchers = (options) ->
  defer = Q.defer()
  res = []

  if options.noMatchers
    defer.resolve()
  else
    exists options.matchersRoot, (exist) ->
      if exist
        emitter = walk options.matchersRoot
        emitter.on 'file', (p, stat) -> res.push path.relative '.', p
        emitter.on 'end', -> defer.resolve res
      else
        defer.resolve([])

  defer.promise

findHelpers = (options) ->
  defer = Q.defer()
  res = []

  if options.noHelpers
    defer.resolve()
  else
    exists options.helpersRoot, (exist) ->
      if exist
        emitter = walk options.helpersRoot
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
  paths = [
    'assets/js/spectacular.js'
    'assets/js/browser_reporter.js'
  ]
  findHelpers(options)
  .then (helpers) ->
    paths = paths.concat helpers
    findMatchers options
  .then (matchers) ->
    paths = paths.concat matchers
    globPaths options.globs
  .then (specs) ->
    paths = paths.concat specs
  .then ->
    globPaths options.sources
  .then (sources) ->
    """
      <!doctype html>
      <html>
        <head>
          <script>
            options = #{util.inspect options};
            paths = #{util.inspect paths[3..]};
          </script>
          <link href='http://fonts.googleapis.com/css?family=Roboto:400,100,300' rel='stylesheet' type='text/css'>
          <link rel="stylesheet" href="assets/css/spectacular.css"/>
          <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/font-awesome/3.0.2/css/font-awesome.min.css"/>
          #{(scriptNode p for p in sources).join '\n'}
          #{(scriptNode p for p in paths).join '\n'}
        </head>
        <body></body>
      </html>
    """

exports.run = (options) ->
  defer = Q.defer()
  app = express()

  app.get '/', (req, res) ->
    generateSpecRunner(options).then (html) ->
      res.send html

  app.use '/assets/js', express.static path.resolve SPECTACULAR_ROOT, 'lib'
  app.use '/assets/css', express.static path.resolve SPECTACULAR_ROOT, 'css'
  app.use '/', (req, res, next) ->
    content = fs.readFileSync(path.resolve "./#{req.url}").toString()

    if /\.coffee$/.test(req.url) and options.coffee
      {compile} = require 'coffee-script'
      content = compile content

    res.send content

  port = process.env.PORT or 5000
  app.listen port
  console.log "  server listening on port #{port.toString().cyan}"

  if options.phantomjs
    console.log "  running tests on phantomjs"
    phantom = spawn 'phantomjs', ['./lib/spectacular_phantomjs.js']
    phantom.stdout.on 'data', (data) -> util.print data.toString()
    phantom.stderr.on 'data', (data) -> util.print data.toString()
    phantom.on 'exit', (status) ->
      process.exit status

  defer.promise

