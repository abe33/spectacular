Q = require 'q'
glob = require 'glob'
path = require 'path'
util = require 'util'
require 'colors'

class Runner
  constructor: (@root, @options) ->
    @results = []

  run: =>
    promise = @globPaths()
    .then(@loadSpecs)
    .then(@executeSpecs)
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
    @stack = []
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

    @results.push example.result

  hasFailures: -> @results.some (result) -> not result.success

  printResults: =>
    console.log '\n'
    if @hasFailures()
      for result in @results
        if result.state is 'failure'
          if result.expectations.length > 0
            for expectation in result.expectations
              unless expectation.success
                console.log expectation.description.red
                console.log expectation.message
          else
            console.log result.example.description.red
            console.log result.example.promise.reason
      1
    else
      console.log "\n\nFinished in ...s"
      0

module.exports = Runner
