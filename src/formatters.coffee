
fs = require 'fs'
util = require 'util'
utils = require './utils'

## StackFormatter

class exports.StackFormatter
  constructor: (@error, @options) ->

  format: ->
    stack = @error.stack.split('\n').filter (line) -> /^\s{4}at.*$/g.test line
    res = '\n'
    res += @formatErrorInFile stack[0] if @options.showSource

    if @options.longTrace
      res += "\n\n#{stack.join '\n'}\n"
    else
      res += "\n#{
        stack[0..5]
        .concat(
          "    ...\n\n    use --long-trace option to view the #{
            stack.length - 6
          } remaining lines"
        ).join('\n')
      }\n\n"

    res = res.grey unless @options.noColors
    res

  formatErrorInFile: (line) ->
    re = /\((.*):(.*):(.*)\)/
    return '' unless re.test line
    [match, file, line, column] = re.exec line

    "\n#{@getLines(file, parseInt(line), parseInt(column))}\n"

  getLines: (file, line, column) ->
    fileContent = fs.readFileSync(file).toString()

    if @options.coffee and file.indexOf('.coffee') isnt -1
      {compile} = require 'coffee-script'
      fileContent = compile fileContent, bare: true

    fileContent = fileContent.split('\n').map (l,i) =>
      "    #{utils.padRight i + 1} | #{l}"

    @insertColumnLine fileContent, line, column

    startLine = Math.max(1, line - 3) - 1
    endLine = Math.min(fileContent.length, line + 2) - 1

    lines = fileContent[startLine..endLine].join('\n')
    lines

  insertColumnLine: (content, line, column) ->
    if line is content.length
      content.push line
    else
      content.splice line, 0, "         |#{utils.padRight('^', column-2)}"


## ResultsFormatter

class exports.ResultsFormatter
  constructor: (@root, @options, @env) ->
    @errorsCounter = 1
    @failuresCounter = 1
    @errors = []
    @failures = []
    @skipped = []
    @pending = []
    @results = []
    @examples = []

  registerResult: (example) ->
    @printExampleResult example
    @results.push example.result
    @examples.push example

  hasFailures: ->
    @results.some (result) -> result.state in ['failure', 'skipped', 'errored']

  printResults: (lstart, lend, sstart, send) ->
    console.log @buildResults lstart, lend, sstart, send

  buildResults: (lstart, lend, sstart, send) ->
    res = '\n\n'
    for result in @results
      switch result.state
        when 'pending' then @pending.push result.example
        when 'skipped' then @skipped.push result.example
        when 'errored'
          @errors.push result.example
          res += @formatExampleError result.example
        when 'failure'
          @failures.push result.example
          if result.expectations.length > 0
            for expectation in result.expectations
              unless expectation.success
                res += @formatExpectationFailure expectation
          else
            res += @formatExampleFailure result.example

    res += @formatResume()
    res += @formatTimers(lstart, lend, sstart, send)
    res += @formatCounters()
    res += '\n'

  printExampleResult: (example) ->
    res = @formatExampleResult example
    util.print res if res?

  formatExampleResult: (example) ->
    if @options.noColors
      switch example.result.state
        when 'pending' then '*'
        when 'skipped' then 'x'
        when 'failure' then 'F'
        when 'errored' then 'E'
        when 'success' then '.'

    else
      switch example.result.state
        when 'pending' then '*'.yellow
        when 'skipped' then 'x'.magenta
        when 'failure' then 'F'.red
        when 'errored' then 'E'.yellow
        when 'success' then '.'.green

  formatStack: (e) ->
    new exports.StackFormatter(e, @options).format()

  formatExampleFailure: (example) ->
    res =  @failureBadge example.description
    res += @formatError example.examplePromise.reason
    res += '\n'

  formatExpectationFailure: (expectation) ->
    res = @failureBadge expectation.description
    res += '\n'
    res += @formatMessage expectation.message
    res += @formatStack expectation.trace if @options.trace
    res += '\n'

  formatExampleError: (example) ->
    res =  @errorBadge example.description
    res += @formatError example.examplePromise.reason

  formatError: (error) ->
    res = @formatMessage error.message
    res += @formatStack error if @options.trace

  failureBadge: (message) ->
    badge = ' FAIL '
    if @options.noColors
      "#{badge} #{message}\n"
    else
      "#{badge.inverse.bold}[#{@failuresCounter++}] #{message}\n".red

  errorBadge: (message) ->
    badge = ' ERROR '
    if @options.noColors
      "#{badge} #{message}\n"
    else
      "#{badge.inverse.bold}[#{@errorsCounter++}] #{message}\n".yellow

  formatMessage: (message) -> "\n#{utils.indent message}"

  formatResume: ->
    res = ''
    res += @mapDescription('Errors:', @errors, 'yellow') if @errors.length > 0
    res += @mapDescription('Failures:', @failures, 'red') if @failures.length > 0
    res += @mapDescription('Skipped:', @skipped, 'magenta') if @skipped.length > 0
    res += @mapDescription('Pending:', @pending, 'yellow') if @pending.length > 0
    res

  mapDescription: (desc, array, color) ->
    res = "    #{desc}\n\n"
    res += array.map((e, i) ->
      "      #{i + 1}. #{e.description}"
    ).join('\n')
    res = res[color] unless @options.noColors
    "#{res}\n\n"

  formatTimers: (loadStartedAt, loadEndedAt, specsStartedAt, specsEndedAt) ->
    loadDuration = @formatDuration loadStartedAt, loadEndedAt
    specsDuration = @formatDuration specsStartedAt, specsEndedAt

    """
    Specs loaded in #{loadDuration}
    Finished in #{specsDuration}

    """

  formatCounters: ->
    failures = @failures.length
    errored = @errors.length
    skipped = @skipped.length
    pending = @pending.length
    success = @examples.length - failures - errored - pending - skipped
    assertions = @results.reduce ((a, b) -> a + b.expectations.length), 0
    @formatResults success, failures, errored, skipped, pending, assertions

  formatResults: (s, f, e, sk, p, a) ->
    toggle = utils.toggle
    utils.squeeze("#{@formatCount s, 'success', 'success', toggle f, 'green'},
    #{@formatCount a, 'assertion', 'assertions', toggle f, 'green'},
    #{@formatCount f, 'failure', 'failures', toggle f, 'green', 'red'},
    #{@formatCount e, 'error', 'errors', toggle e, 'green', 'yellow'},
    #{@formatCount sk, 'skipped', 'skipped', toggle sk, 'green', 'magenta'},
    #{@formatCount p, 'pending', 'pending', toggle p, 'green', 'yellow'}")

  formatDuration: (start, end) ->
    duration = (end.getTime() - start.getTime()) / 1000
    duration = "#{Math.max 0, duration}s"
    duration = duration.yellow unless @options.noColors
    duration

  formatCount: (value, singular, plural, color) ->
    s = ("#{value} #{
      if value is 0
        plural
      else if value is 1
        singular
      else
        plural
    }")
    s = s[color] if color? and not @options.noColors
    s


