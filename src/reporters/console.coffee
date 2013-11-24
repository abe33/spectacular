
## ConsoleReporter

class spectacular.ConsoleReporter
  @include spectacular.EventDispatcher

  @getDefault: (options) ->
    reporter = new ConsoleReporter options
    f = spectacular.formatters.console

    reporter.resultFormatters.push f.ResumeFormatter if options.resume
    reporter.resultFormatters.push f.ProfileFormatter if options.profile

    reporter.resultFormatters.push f.DurationFormatter
    reporter.resultFormatters.push f.SeedFormatter
    reporter.resultFormatters.push f.ResultsFormatter

    reporter.progressFormatters['documentation'] = f.DocumentationFormatter
    reporter.progressFormatters['progress'] = f.ProgressFormatter

    reporter.exampleResultsFormatters.push f.ExampleResultsFormatter

    reporter

  constructor: (@options) ->
    @resultFormatters = []
    @exampleResultsFormatters = []
    @progressFormatters = {}

  onMessage: (event) => @dispatch event

  onResult: (event) =>
    example = event.target
    @printExampleResult example

  onEnd: (event) =>
    runnerResults = event.target
    runner = runnerResults.runner
    options = @options

    printResult = (example, i) =>
      res = ''
      promise = spectacular.Promise.unit('')
      @exampleResultsFormatters.forEach (formatter) ->
        promise = promise.then (result) ->
          res += result
          new formatter(example, options, i+1).format()

      promise.then (result) ->
        res + result

    errors = runnerResults.errors.map printResult
    failures = runnerResults.failures.map printResult

    allResults = ['\n\n']
    promise = spectacular.Promise.unit([])

    if errors.length > 0
      promise = promise.then(-> spectacular.Promise.all(errors))

    if failures.length > 0
      promise = promise.then (results) ->
        allResults = allResults.concat results
        spectacular.Promise.all(failures)

    if @resultFormatters.length > 0
      promise = promise.then (results) =>
        allResults = allResults.concat results
        spectacular.Promise.all @resultFormatters.map (formatter) ->
          new formatter(runner, runnerResults).format()

    promise.then (results) =>
      allResults = allResults.concat results
      @dispatch new spectacular.Event 'report', allResults.join('') + '\n\n'

    .fail (reason) ->
      console.log reason.stack

  printExampleResult: (example) =>
    state = example.result.state
    res = new @progressFormatters[@options.format](example, @options).format()
    @dispatch new spectacular.Event 'message', res if res?
