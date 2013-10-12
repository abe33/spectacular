spectacular.formatters.console = {}

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
  constructor: (@runner) ->
    {@options} = @runner

  format: ->
    promise = new spectacular.Promise

    {loadStartedAt, loadEndedAt, specsStartedAt, specsEndedAt} = @runner

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
  constructor: (@runner) ->
    {@examples, @options} = @runner

  format: ->
    promise = new spectacular.Promise

    sortedExamples = @examples.sort((a, b) -> b.duration - a.duration)[0..9]
    totalDuration = @runner.specsEndedAt.getTime() - @runner.specsStartedAt.getTime()

    topSlowest = sortedExamples.reduce ((a,b) -> a + b.duration), 0
    rate = Math.floor(topSlowest / totalDuration * 10000) / 100

    res = "  Top 10 slowest examples (#{topSlowest / 1000} seconds, #{rate}% of total time)\n\n"
    for example in sortedExamples
      duration = "#{Math.floor(example.duration) / 1000} seconds"
      res += "    #{spectacular.utils.colorize duration, 'red', @options.colors} #{example.fullDescription}\n"

    promise.resolve "#{res}\n"

    promise

class spectacular.formatters.console.ErrorStackFormatter
  constructor: (@stack, @options) ->
    @parser = new spectacular.errors.ErrorParser @stack

  format: () ->
    promise = new spectacular.Promise

    lines = @parser.lines
    lines = lines.map (line) -> line.replace /^\s+/, '    '
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

