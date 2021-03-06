

class spectacular.formatters.console.ErrorSourceFormatter
  constructor: (@options, @file, line, column=1) ->
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

