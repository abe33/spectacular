spectacular.formatters.console = {}

{CHAR_MAP, COLOR_MAP, BADGE_MAP} = spectacular.formatters

class spectacular.formatters.console.ProgressFormatter
  constructor: (@example, @options) ->

  format: ->
    state = @example.result.state
    spectacular.utils.colorize CHAR_MAP[state], COLOR_MAP[state], @options.colors

class spectacular.formatters.console.DocumentationFormatter
  constructor: (@example, @options) ->

  format: ->
    state = @example.result.state

    @options.lastDepth ||= 0
    @options.lastAncestorsStack ||= []

    ancestors = @example.ancestors.filter (e) -> e.ownDescription isnt ''
    dif = @cropAncestors ancestors, @options.lastAncestorsStack
    start = ancestors.length - dif.length
    res = @formatDocumentation @example, dif, start, COLOR_MAP[state]

    @options.lastAncestorsStack = ancestors
    res

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
      spectacular.utils.colorize(utils.strip(example.ownDescriptionWithExpectations), color, @options.colors),
      (start + 1) * 2
    )

    @options.lastDepth = start

    res

  cropAncestors: (ancestors, lastAncestorsStack) ->
    a = []
    a.push elder for elder in ancestors when elder not in lastAncestorsStack
    a



class spectacular.formatters.console.ResultsFormatter
  constructor: (@runner, @results) ->
    {@options} = @runner
    {@errors, @failures, @skipped, @pending, @results} = @results

  format: ->
    promise = new spectacular.Promise

    failures = @failures.length
    errored = @errors.length
    skipped = @skipped.length
    pending = @pending.length
    success = @runner.examples.length - failures - errored - pending - skipped
    assertions = @results.reduce ((a, b) -> a + b.expectations.length), 0

    promise.resolve @formatResults success, failures, errored, skipped, pending, assertions

    promise

  formatResults: (success, failures, errors, skipped, pending, assertions) ->
    toggle = spectacular.utils.toggle
    hasError = failures + errors

    res = []
    res.push @formatCount success, 'success', 'success', toggle hasError, 'green'
    res.push @formatCount assertions, 'assertion', 'assertions', toggle hasError, 'green'
    res.push @formatCount failures, 'failure', 'failures', toggle hasError, 'green', 'red'
    res.push @formatCount errors, 'error', 'errors', toggle errors, 'green', 'yellow'
    res.push @formatCount skipped, 'skipped', 'skipped', toggle skipped, 'green', 'magenta'
    res.push @formatCount pending, 'pending', 'pending', toggle pending, 'green', 'yellow'

    "  #{res.join ', '}\n"

  formatCount: (value, singular, plural, color) ->
    s = ("#{value} #{
      if value is 0
        plural
      else if value is 1
        singular
      else
        plural
    }")
    s = spectacular.utils.colorize s, color, @options.colors if color?
    s

class spectacular.formatters.console.ExampleResultsFormatter
  constructor: (@example, @options, @id) ->

  format: ->
    result = @example.result
    promise = new spectacular.Promise
    switch result.state
      when 'errored'
        @formatExample(@example.fullDescription, @example.reason, result.state)
        .then (msg) ->
          promise.resolve msg
      when 'failure'
        if result.expectations.length > 0

          promises = []
          for expectation in result.expectations
            unless expectation.success
              reason =
                message: expectation.message
                stack: expectation.trace.stack
              promises.push @formatExample(expectation.fullDescription, reason, result.state)

          spectacular.Promise.all(promises)
          .then (results) ->
            promise.resolve results.join ''
        else
          @formatExample(@example.fullDescription, @example.reason, result.state)
          .then (msg) ->
            promise.resolve msg
      else
        promise.resolve ''

    promise

  formatExample: (message, error, state) ->
    errorFormatter = new spectacular.formatters.console.ErrorFormatter error, @options

    errorFormatter.format().then (errorTxt) =>
      res = @badge message, BADGE_MAP[state], COLOR_MAP[state]
      res + '\n' + errorTxt


  badge: (message, label, color) ->
    c = spectacular.utils.colorize
    hc = @options.colors

    res = ''
    res += c(c(" #{label} ".toUpperCase(), 'inverse', hc), 'bold', hc)
    res += " #{@id} "
    res += c(' ', 'inverse', hc)
    res += ' '
    res += message
    res = c(res, color, hc)
    res


class spectacular.formatters.console.ResumeFormatter
  constructor: (@runner, @results) ->
    {@options} = @runner
    {@errors, @failures, @skipped, @pending} = @results

  format: ->
    promise = new spectacular.Promise

    res = ''
    res += @formatResume('Errors:', @errors, 'yellow') if @errors.length > 0
    res += @formatResume('Failures:', @failures, 'red') if @failures.length > 0
    res += @formatResume('Skipped:', @skipped, 'magenta') if @skipped.length > 0
    res += @formatResume('Pending:', @pending, 'yellow') if @pending.length > 0

    promise.resolve res

    promise

  formatResume: (desc, array, color) ->
    res = "    #{desc}\n\n"
    res += array.map((e, i) ->
      "      #{i + 1}. #{e.fullDescription}"
    ).join('\n')
    "#{spectacular.utils.colorize res, color, @options.colors}\n\n"

class spectacular.formatters.console.SeedFormatter
  constructor: (@runner) ->
    {@options} = @runner
    {@seed} = @options

  format: ->
    promise = new spectacular.Promise

    promise.resolve "  Seed #{spectacular.utils.colorize @seed.toString(), 'cyan', @options.colors}\n\n"

    promise

class spectacular.formatters.console.DurationFormatter
  constructor: (@runner, @results) ->
    {@options} = @runner

  format: ->
    promise = new spectacular.Promise

    {loadStartedAt, loadEndedAt, specsStartedAt, specsEndedAt} = @results

    if loadStartedAt? and loadEndedAt?
      loadDuration = @formatDuration loadStartedAt, loadEndedAt

    specsDuration = @formatDuration specsStartedAt, specsEndedAt

    res = ''
    res += "  Specs loaded in #{loadDuration}\n" if loadDuration?
    res += "  Finished in #{specsDuration}\n\n"

    promise.resolve res

    promise

  formatDuration: (start, end) ->
    duration = (end.getTime() - start.getTime()) / 1000
    spectacular.utils.colorize "#{Math.max 0, duration}s", 'yellow', @options.colors

class spectacular.formatters.console.ProfileFormatter
  constructor: (@runner, @results) ->
    {@examples, @options} = @runner

  format: ->
    promise = new spectacular.Promise

    sortedExamples = @examples.sort((a, b) -> b.duration - a.duration)[0..9]
    totalDuration = @results.specsEndedAt.getTime() - @results.specsStartedAt.getTime()

    topSlowest = sortedExamples.reduce ((a,b) -> a + b.duration), 0
    rate = Math.floor(topSlowest / totalDuration * 10000) / 100

    res = "  Top 10 slowest examples (#{topSlowest / 1000} seconds, #{rate}% of total time)\n\n"
    for example in sortedExamples
      duration = "#{Math.floor(example.duration) / 1000} seconds"
      res += "    #{spectacular.utils.colorize duration, 'red', @options.colors} #{example.fullDescription}\n"

    promise.resolve "#{res}\n"

    promise

class spectacular.formatters.console.ErrorFormatter
  constructor: (@error, @options) ->

  format: ->
    promise = new spectacular.Promise
    formatters = spectacular.formatters.console

    res = @formatMessage @error.message

    if @error.stack?
      stackFormatter = new formatters.ErrorStackFormatter @error.stack, @options
      res += '\n'

      if @options.showSource
        {file, line, column} = stackFormatter.parser.details(stackFormatter.parser.lines[0])
        fileFormatter = new formatters.ErrorSourceFormatter @options, file, line, column

        fileFormatter
        .format()
        .then (result) =>
          res += spectacular.utils.colorize result, 'grey', @options.colors
          stackFormatter.format()
        .then (result) ->
          res += result
          promise.resolve res
        .fail (reason) ->
          console.log reason
          promise.resolve res
      else
        res += stackFormatter.format()
        promise.resolve res
    else
      promise.resolve res

    promise

  formatMessage: (message) -> "\n#{spectacular.utils.indent message or ''}"


class spectacular.formatters.console.ErrorStackFormatter
  constructor: (@stack, @options) ->
    @parser = new spectacular.errors.ErrorParser @stack

  format: () ->
    promise = new spectacular.Promise

    lines = @parser.lines
    lines = lines.map (line) -> line.replace /^\s+/, '    '

    unless @options.longTrace
      l = lines.length
      lines = lines[0..5]
      l = l - lines.length
      if l isnt 0
        lines.push "\n    use the --long-trace option to view the #{l} remaining lines"

    stack = "\n#{lines.join '\n'}\n\n"
    promise.resolve spectacular.utils.colorize stack, 'grey', @options.colors

    promise


class spectacular.formatters.console.ErrorSourceFormatter
  constructor: (@options, @file, line, column=0) ->
    @line = parseInt line
    @column = parseInt column

  format: ->
    promise = new spectacular.Promise

    if @options.hasSourceMap(@file)
      @options.getOriginalSourceFor(@file, @line, @column).then (res) =>
        promise.resolve @_format res
    else
      @options.loadFile(@file).then (content) =>
        promise.resolve @_format {content, line: @line, column: @column}

    promise

  _format: ({content, line, column}) =>
    {lines, start, end} = @selectLines content, line
    columnIndicator = @columnIndicator column

    if line isnt end
      lines.splice(line - start + 1, 0, columnIndicator)
    else
      lines.push columnIndicator

    "\n#{lines.join '\n'}\n"

  selectLines: (content, line) ->

    lines = content.split('\n')
    startLine = Math.max(1, line - 3) - 1
    endLine = Math.min(lines.length, line + 1) - 1

    lines = lines[startLine..endLine].map (l, i) ->
      pad = if l.length > 0 then ' ' else ''
      "    #{utils.padRight i + startLine + 1} |#{pad}#{l}"

    {lines, start: startLine + 1, end: endLine + 1}

  columnIndicator: (column) ->
    "         | #{spectacular.utils.padRight '^', column}"

