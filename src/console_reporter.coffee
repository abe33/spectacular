
## StackReporter

PROGRESS_CHAR_MAP =
  pending: '*'
  skipped: 'x'
  failure: 'F'
  errored: 'E'
  success: '.'

PROGRESS_COLOR_MAP =
  pending: 'yellow'
  skipped: 'magenta'
  failure: 'red'
  errored: 'yellow'
  success: 'green'

spectacular.StackReporter = spectacular.formatters.console.ErrorFormatter

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

    reporter

  constructor: (@options) ->
    @resultFormatters = []
    @progressFormatters = []
    @exampleResultsFormatters = [
      spectacular.formatters.console.ExampleResultsFormatter
    ]

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
    res = @formatExampleResult example
    @dispatch new spectacular.Event 'message', res if res?

  formatExampleResult: (example) ->
    state = example.result.state
    if @options.documentation
      @lastDepth ||= 0
      @lastAncestorsStack ||= []

      ancestors = example.ancestors.filter (e) -> e.ownDescription isnt ''
      dif = @cropAncestors ancestors, @lastAncestorsStack
      start = ancestors.length - dif.length
      res = @formatDocumentation example, dif, start, PROGRESS_COLOR_MAP[state]

      @lastAncestorsStack = ancestors
      res
    else
      @colorize PROGRESS_CHAR_MAP[state], PROGRESS_COLOR_MAP[state]

  formatDocumentation: (example, stack, start, color) ->
    reverseStack = []
    reverseStack.unshift e for e in stack
    res = ''

    for e,i in reverseStack
      res += '\n' if i is 0
      res += '\n'
      res += utils.indent(utils.strip(e.ownDescription), (start + 1) * 2)
      start += 1

    res += '\n'
    res += utils.indent(
      @colorize(utils.strip(example.ownDescriptionWithExpectations), color),
      (start + 1) * 2
    )

    @lastDepth = start

    res

  cropAncestors: (ancestors, lastAncestorsStack) ->
    a = []
    a.push elder for elder in ancestors when elder not in lastAncestorsStack
    a

  colorize: (str, color) ->
    if str? and @options.colors and str?[color] then str[color] else str


