fs = require 'fs'
Q = require 'q'
glob = require 'glob'
path = require 'path'
express = require 'express'
walk = require 'walkdir'
util = require 'util'

SPECTACULAR_ROOT = path.resolve __dirname, '..'

findMatchers = (options) ->
  defer = Q.defer()
  res = []

  if options.noMatchers
    defer.resolve()
  else
    emitter = walk options.matchersRoot
    emitter.on 'file', (p, stat) -> res.push path.relative '.', p
    emitter.on 'end', -> defer.resolve res

  defer.promise

findHelpers = (options) ->
  defer = Q.defer()
  res = []

  if options.noHelpers
    defer.resolve()
  else
    emitter = walk options.helpersRoot
    emitter.on 'file', (p, stat) -> res.push path.relative '.', p
    emitter.on 'end', -> defer.resolve res

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
    """
      <!doctype html>
      <html>
        <head>
          #{scriptNode 'http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js'}
          <script>
            options = #{util.inspect options};
            paths = #{util.inspect paths[3..]};
          </script>
          <link href='http://fonts.googleapis.com/css?family=Roboto:400,100,300' rel='stylesheet' type='text/css'>
          <link rel="stylesheet" href="assets/css/spectacular.css"/>
          <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/font-awesome/3.0.2/css/font-awesome.min.css"/>
          #{(scriptNode p for p in paths).join '\n'}
        </head>
        <body></body>
      </html>
    """

exports.run = (options) ->
  app = express()

  app.get '/', (req, res) ->
    generateSpecRunner(options).then (html) ->
      res.send html

  app.use '/assets/js', express.static path.resolve SPECTACULAR_ROOT, 'lib'
  app.use '/assets/css', express.static path.resolve SPECTACULAR_ROOT, 'css'
  app.use '/specs', (req, res, next) ->
    content = fs.readFileSync(path.resolve "./specs#{req.url}").toString()

    if /\.coffee$/.test(req.url) and options.coffee
      {compile} = require 'coffee-script'
      content = compile content

    res.send content

  app.listen 5000
  console.log 'Server listening on port 5000'.cyan

  Q.defer().promise

