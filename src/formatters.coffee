
fs = require 'fs'
util = require 'util'
utils = require './utils'

## StackFormatter

class exports.StackFormatter
  constructor: (@error, @options) ->

  print: ->
    stackString = @error.stack.replace(/^[^ ]{4}.*\n/, '')
    stack = stackString.split('\n')
    @printErrorInFile stack[0] if @options.showSource

    if @options.longTrace
      res = "\n\n#{stackString}"
    else
      res = "\n#{
        stack[0..5]
        .concat(
          "    ...\n\n    use --long-trace option to view the #{
            stack.length - 6
          } remaining lines"
        ).join('\n')
      }"

    res = res.grey unless @options.noColors
    res = "#{res}\n" unless res.substr(-1) is '\n'
    console.log res

  printErrorInFile: (line) ->
    re = /\((.*):(.*):(.*)\)/
    [match, file, line, column] = re.exec line

    console.log ''
    console.log @getLines(file, parseInt(line), parseInt(column))

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
    lines = lines.grey unless @options.noColors
    lines

  insertColumnLine: (content, line, column) ->
    if line is content.length
      content.push line
    else
      content.splice line, 0, "         |#{utils.padRight('^', column-2)}"


## ResultsFormatter

class exports.ResultsFormatter
  constructor: (@root, @options) ->
    @results = []
    @examples = []

  registerResult: (example) ->
    @printExampleResult example
    @results.push example.result
    @examples.push example

  hasFailures: ->
    @results.some (result) -> result.state in ['failure', 'skipped', 'errored']

  printExampleResult: (example) ->
    if @options.noColors
      switch example.result.state
        when 'pending' then util.print '*'
        when 'skipped' then util.print 'x'
        when 'failure' then util.print 'F'
        when 'errored' then util.print 'E'
        when 'success' then util.print '.'

    else
      switch example.result.state
        when 'pending' then util.print '*'.yellow
        when 'skipped' then util.print 'x'.magenta
        when 'failure' then util.print 'F'.red
        when 'errored' then util.print 'E'.yellow
        when 'success' then util.print '.'.green

  printStack: (e) ->
    new exports.StackFormatter(e, @options).print()

  printFailure: (message) ->
    badge = ' FAIL '
    console.log if @options.noColors
      "#{badge} #{message}"
    else
      "#{badge.inverse.bold} #{message}".red

  printError: (message) ->
    badge = ' ERROR '
    console.log if @options.noColors
      "#{badge} #{message}"
    else
      "#{badge.inverse.bold} #{message}".yellow

  printMessage: (message) ->
    console.log "\n#{utils.indent message}"

  printResults: (lstart, lend, sstart, send) ->
    console.log '\n'
    if @hasFailures()
      for result in @results
        switch result.state
          when 'errored'
            @printError result.example.description
            @printMessage result.example.examplePromise.reason.message
            @printStack result.example.examplePromise.reason if @options.trace
          when 'failure'
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

    console.log @formatTimers(lstart, lend, sstart, send)
    console.log @formatCounters()
    console.log ''

  formatTimers: (loadStartedAt, loadEndedAt, specsStartedAt, specsEndedAt) ->
    loadDuration = @formatDuration loadStartedAt, loadEndedAt
    specsDuration = @formatDuration specsStartedAt, specsEndedAt

    """
    Specs loaded in #{loadDuration}
    Finished in #{specsDuration}
    """

  formatCounters: ->
    success = @examples.filter((e)-> e.result.state is 'success').length
    failures = @examples.filter((e)-> e.result.state is'failure').length
    errored = @examples.filter((e)-> e.result.state is 'errored').length
    skipped = @examples.filter((e)-> e.result.state is 'skipped').length
    pending = @examples.filter((e)-> e.result.state is 'pending').length
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
    duration = (end.getMilliseconds() - start.getMilliseconds()) / 1000
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


