Q = require 'q'
glob = require 'glob'
path = require 'path'
util = require 'util'
require 'colors'

class Runner
  constructor: (@root, @options) ->
    @results = []
    @examples = []
    @stack = []

  run: =>
    promise = @globPaths()
    .then (paths) =>
      @loadStartedAt = new Date()
      paths
    .then(@loadSpecs)
    .then =>
      @loadEndedAt = new Date()
      @specsStartedAt = new Date()
    .then(@executeSpecs)
    .then =>
      @specsEndedAt = new Date()
    .then(@printResults)

  globPaths: =>
    Q.all(@glob p for p in @options.globs).then (results) =>
      paths = []
      results.forEach (a) -> paths = paths.concat a
      console.log 'paths:', paths if @options.verbose
      paths

  glob: (path) ->
    defer = Q.defer()
    glob path, (err, res) ->
      return defer.reject err if err
      defer.resolve res

    defer.promise

  loadSpecs: (paths) =>
    require path.resolve('.', p) for p in paths

  executeSpecs: =>
    console.log ''
    @register example for example in @root.allExamples
    defer = Q.defer()
    @nextExample defer
    defer.promise

  nextExample: (defer) =>
    if @stack.length is 0
      defer.resolve()
    else
      nextExample = @stack.shift()

      global.currentExample = nextExample
      nextExample.run()
      .then =>
        @registerResults nextExample
        @nextExample defer
      .fail (reason) =>
        @registerResults nextExample
        @nextExample defer

  register: (example) =>
    @stack.push example

  registerResults: (example) ->
    global.currentExample = null

    switch example.result.state
      when 'pending' then util.print '*'.yellow
      when 'skipped' then util.print 'x'.magenta
      when 'failure' then util.print 'F'.red
      when 'success' then util.print '.'.green

    @examples.push example
    @results.push example.result

  hasFailures: ->
    @results.some (result) -> result.state in ['failure', 'skipped']

  printStack: (e) ->
    console.log "\n\n#{e.stack.replace(/^.*\n/, '').grey}"

  printFailure: (message) ->
    console.log "#{' FAIL '.inverse.bold} #{message}".red

  printMessage: (message) ->
    console.log "\n    #{message}"


  printResults: =>
    console.log '\n'
    if @hasFailures()
      for result in @results
        if result.state is 'failure'
          if result.expectations.length > 0
            for expectation in result.expectations
              unless expectation.success
                @printFailure expectation.description
                @printMessage expectation.message
                @printStack expectation.trace if @options.trace
                console.log '\n'
          else
            @printFailure result.example.description
            @printMessage result.example.examplePromise.reason.message
            @printStack result.example.examplePromise.reason if @options.trace
            console.log '\n'
      @printDetails()
      1
    else
      @printDetails()
      0

  duration: (start, end) ->
    duration = (end.getMilliseconds() - start.getMilliseconds()) / 1000
    "#{duration}s".yellow

  printDetails: ->
    success = @examples.filter((e)-> e.result.state is 'success').length
    failures = @examples.filter((e)-> e.result.state is 'failure').length
    skipped = @examples.filter((e)-> e.result.state is 'skipped').length
    pending = @examples.filter((e)-> e.result.state is 'pending').length
    assertions = @results.reduce ((a, b) -> a + b.expectations.length), 0
    loadDuration = @duration @loadStartedAt, @loadEndedAt
    specsDuration = @duration @specsStartedAt, @specsEndedAt

    console.log """
      Specs loaded in #{loadDuration}
      Finished in #{specsDuration}
      #{@formatResults success, failures, skipped, pending, assertions}

      """

  formatResults: (s, f, sk, p, a) ->

    "#{@formatCount s, 'success', 'success', @toggle f, 'green'},
    #{@formatCount a, 'assertion', 'assertions', @toggle f, 'green'},
    #{@formatCount f, 'failure', 'failures', @toggle f, 'green', 'red'},
    #{@formatCount sk, 'skipped', 'skipped', @toggle sk, 'green', 'red'},
    #{@formatCount p, 'pending', 'pending', @toggle p, 'green', 'yellow'}
    ".replace /\s+/g, ' '

  formatCount: (value, singular, plural, color) ->
    s = ("#{value} #{
      if value is 0
        plural
      else if value is 1
        singular
      else
        plural
    }")
    s = s[color] if color?
    s

  toggle: (value, c1, c2) ->
    if value is 0 then c1 else c2


module.exports = Runner
