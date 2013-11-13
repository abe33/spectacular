
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

a = document.createElement 'a'
a.href = window.location
params = new spectacular.URLParameters(a.search[1..])

spectacular.options[k] = v for k,v of params when params.hasOwnProperty k


spectacular.BrowserMethods(spectacular.options)

spectacular.env = new spectacular.Environment(spectacular.options)
spectacular.env.globalize()
spectacular.env.runner.loadStartedAt = new Date()

viewerSize = -> Math.min(document.body.clientWidth - 60, 500)

window.env = spectacular.env

displayErrors = (msg, file, line) ->
  formatter = new spectacular.formatters.console.ErrorSourceFormatter spectacular.options, file, line

  formatter.format().then (src) ->
    node = document.createElement 'div'
    node.innerHTML = spectacular.templates.error(message: msg, source: src)
    document.body.appendChild node

hasErrors = false
errors = []
window.onerror = (e) ->
  hasErrors = true
  displayErrors.apply null, arguments
  true

currentWindowOnload = window.onload
window.onload = ->
  do currentWindowOnload if currentWindowOnload?

  return if hasErrors

  utils = spectacular.utils

  if spectacular.options.verbose
    console.log utils.indent utils.inspect spectacular.options
    console.log utils.indent utils.inspect spectacular.paths
    console.log '\n  Scripts loaded:'
    scripts = document.querySelectorAll('script[src]')
    for s in scripts
      console.log "    #{s.attributes.getNamedItem("src")?.value}"

    console.log ''

  reporter = new spectacular.BrowserReporter(
    spectacular.env.runner,
    [
      new spectacular.widgets.RunnerProgress
      new spectacular.widgets.ExamplesList
      new spectacular.widgets.ExampleViewer
      new spectacular.widgets.ExamplesSearch
    ]
  )

  reporter.init()
  spectacular.env.runner.loadEndedAt = new Date()
  spectacular.env.runner.specsStartedAt = new Date()

  spectacular.env.run().fail (reason) ->
    console.log reason.stack
