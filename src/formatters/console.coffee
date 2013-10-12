spectacular.formatters.console = {}

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

