
class spectacular.BrowserReporter
  constructor: (@runner, @widgets) ->
    {@options} = @runner

    @registerEvents()

  registerEvents: ->
    @runner.on 'start', @onStart
    @runner.on 'result', @onResult
    @runner.on 'end', @onEnd

  unregisterEvents: ->
    @runner.off 'start', @onStart
    @runner.off 'result', @onResult
    @runner.off 'end', @onEnd

  init: -> @widgets.forEach (w) => w.init(@runner, this)
  onStart: (e) => @widgets.forEach (w) => w.onStart(e)
  onResult: (e) => @widgets.forEach (w) -> w.onResult e
  onEnd: (e) => @widgets.forEach (w) -> w.onEnd e

spectacular.BrowserMethods = (options) ->
  cache = {}
  loaders = {}

  unless options.loadFile?
    options.loadFile = (file) ->
      promise = new spectacular.Promise

      if file of cache
        setTimeout (-> promise.resolve cache[file]), 0
        return promise

      if file of loaders
        loaders[file].push (data) -> promise.resolve data
        return promise

      req = new XMLHttpRequest()
      req.onload = ->
        data = @responseText
        loaders[file].forEach (f) -> f data

      listener = (data) -> promise.resolve cache[file] = data
      loaders[file] = [listener]

      req.open 'get', file, true
      req.send()

      promise

  unless options.getOriginalSourceFor?
    options.getOriginalSourceFor = (file, line, column) ->
      promise = new spectacular.Promise

      fileSource = null
      @loadFile(@getSourceURLFor file)
      .then (source) =>
        fileSource = source
        @loadFile(@getSourceMapURLFor file)
      .then (sourceMap) =>
        consumer = new window.sourceMap.SourceMapConsumer sourceMap
        {line, column} = consumer.originalPositionFor {line, column}
        promise.resolve {content: fileSource, line, column}
      .fail =>
        @loadFile(file).then (content) ->
          promise.resolve {content, line, column}

      promise

  # These are the concrete methods that you can define to enable source map.
  unless options.hasSourceMap?
    options.hasSourceMap = (file) -> false

  unless options.getSourceURLFor?
    options.getSourceURLFor = (file) ->

  unless options.getSourceMapURLFor?
    options.getSourceMapURLFor = (file) ->

spectacular.paths = spectacular.paths or []
spectacular.options = spectacular.options or {}

defaults =
  coffee: false
  verbose: false
  profile: false
  trace: true
  longTrace: false
  showSource: true
  format: 'progress'
  matchersRoot: './specs/support/matchers'
  helpersRoot: './specs/support/helpers'
  fixturesRoot: './specs/support/fixtures'
  noMatchers: false
  noHelpers: false
  colors: true
  random: true
  seed: null
  server: false
  globs: []


spectacular.options[k] = v for k,v of defaults when not k of spectacular.options

spectacular.BrowserMethods(spectacular.options)

spectacular.env = new spectacular.Environment(spectacular.options)
spectacular.env.globalize()
spectacular.env.runner.loadStartedAt = new Date()

viewerSize = -> Math.min(document.body.clientWidth - 60, 500)

window.env = spectacular.env

currentWindowOnload = window.onload
window.onload = ->
  do currentWindowOnload if currentWindowOnload?
  utils = spectacular.utils

  if spectacular.options.verbose
    console.log utils.indent utils.inspect spectacular.options
    console.log utils.indent utils.inspect spectacular.paths
    console.log '\n  Scripts loaded:'
    scripts = document.querySelectorAll('script[src]')
    for s in scripts
      console.log "    #{s.attributes.getNamedItem("src")?.value}"

    console.log ''

  reporter = new spectacular.BrowserReporter(spectacular.env.runner, [
    new spectacular.widgets.RunnerProgress
    new spectacular.widgets.ExamplesList
    new spectacular.widgets.ExampleViewer
  ])

  reporter.init()
  spectacular.env.runner.loadEndedAt = new Date()
  spectacular.env.runner.specsStartedAt = new Date()

  spectacular.env.run().fail (reason) ->
    console.log reason.stack

  window.snapper = new Snap
    element: document.getElementById('examples')
    minPosition: -viewerSize()

  document.getElementById('viewer').setAttribute 'style', "width: #{viewerSize()}px;"
  snapper.open 'left'

  previousOnResize = document.body.onresize
  document.body.onresize = ->
    snapper.close()
    snapper.settings minPosition: -viewerSize()
    document.getElementById('viewer').setAttribute 'style', "width: #{viewerSize()}px;"


