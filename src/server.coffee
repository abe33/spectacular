fs = require 'fs'
Q = require 'q'
glob = require 'glob'
path = require 'path'
express = require 'express'
walk = require 'walkdir'
util = require 'util'
{spawn} = require 'child_process'
jade = require 'jade'

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
  templates = {}
  relativeRequires = options.requires.filter (p) -> p.indexOf('http') isnt 0
  absoluteRequires = options.requires
  .filter((p) -> p.indexOf('http') is 0)
  .map((p) -> [p] )

  Q.all((findrequire p, options for p in relativeRequires).concat(absoluteRequires))
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
    globPaths [path.resolve SPECTACULAR_ROOT, 'templates/formatters/*.jade']
  .then (tpls) ->

    for p in tpls
      n = p.split('/')
      n = n[n.length - 1]
      n = n.split('.')[0]

      templates[n] = jade.compile(fs.readFileSync(p), client: true, compileDebug: false).toString()
      templates[n] = "<script type='text/javascript'>\nspectacular.templates['#{n}'] = #{templates[n]}\n</script>"
    globPaths options.sources
  .then (sources) ->
    console.log "  #{colorize 'source', 'grey'} #{f}" for f in sources if options.verbose

    options.paths = paths[2..]

    locals =
      options: util.inspect options
      paths: paths
      sources: sources
      pretty: true
      sourceMap: options.sourceMap
      templates: templates

    tplPath = path.resolve SPECTACULAR_ROOT, 'templates/specs.jade'
    console.log "  #{colorize 'template', 'grey'} #{tplPath}" if options.verbose
    tpl = jade.renderFile(tplPath, locals)


exports.run = (options) ->
  colorize = (str, color) -> if options.colors then str[color] else str
  defer = Q.defer()
  app = express()

  app.get '/', (req, res) ->
    generateSpecRunner(options)
    .then (html) ->
      console.log "  #{colorize '200', 'green'} #{colorize 'GET', 'cyan'} /"
      res.send html
    .fail (reason) ->
      console.log "  #{colorize '500', 'red'} #{colorize 'GET', 'cyan'} /"
      console.log reason.stack
      tplPath = path.resolve SPECTACULAR_ROOT, 'templates/500.jade'
      res.status(500).send jade.renderFile tplPath, error: reason.stack

  app.use '/assets/js', express.static path.resolve SPECTACULAR_ROOT, 'lib'
  app.use '/vendor', express.static path.resolve SPECTACULAR_ROOT, 'vendor'
  app.use '/assets/css', express.static path.resolve SPECTACULAR_ROOT, 'css'
  app.use '/', (req, res, next) ->
    serverError = (reason) ->
      tplPath = path.resolve SPECTACULAR_ROOT, 'templates/500.jade'
      console.log "  #{colorize '500', 'red'} #{colorize 'GET', 'cyan'} #{req.url}"
      res.status(500).send jade.renderFile tplPath, error: reason.stack

    notFound = (reason) ->
      tplPath = path.resolve SPECTACULAR_ROOT, 'templates/404.jade'
      console.log "  #{colorize '404', 'red'} #{colorize 'GET', 'cyan'} #{req.url}"
      res.status(404).send jade.renderFile tplPath, error: reason.stack

    if /\.coffee$/.test(req.url) and options.coffee
        try
          content = fs.readFileSync(path.resolve ".#{req.url}").toString()
        catch reason
          return notFound reason

        try
          {compile} = require 'coffee-script'
        catch reason
          return serverError notFound
        content = compile content

    else if /\.coffee\.src$/.test(req.url) and options.coffee
      try
        content = fs.readFileSync(path.resolve ".#{req.url.replace '.coffee.src', '.coffee'}").toString()
      catch reason
        return notFound reason

    else if /\.map$/.test(req.url) and options.coffee
      try
        content = fs.readFileSync(path.resolve ".#{req.url.replace '.map', '.coffee'}").toString()
      catch reason
        return notFound reason

      try
        {compile} = require 'coffee-script'
        compiled = compile content, sourceMap: true
        content = compiled.v3SourceMap
      catch reason
        serverError reason

    else
      try
        content = fs.readFileSync(path.resolve ".#{req.url}").toString()
      catch reason
        return notFound reason

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
