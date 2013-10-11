spectacular.formatters.console = {}

class spectacular.formatters.console.ErrorStackFormatter
  constructor: (@stack) ->
    @parser = new spectacular.errors.ErrorParser @stack

  format: (options={}) ->
    lines = @parser.lines
    lines = lines.map (line) -> line.replace /^\s+/, '    '
    stack = "\n\n#{lines.join '\n'}\n"
    spectacular.utils.colorize stack, 'grey', options.colors

class spectacular.formatters.console.ErrorSourceFormatter
  constructor: (@options, @file, @line, @column=0) ->

  format: ->
    if @options.hasSourceMap(@file)
      promise = @options.getOriginalSourceFor(@file, @line, @column)
      .then(@_format)

    else
      promise = @options.loadFile(@file)
      .then (content) =>
        @_format({content, line: @line, column: @column})

    promise

  _format: ({content, line, column}) =>
    promise = new spectacular.Promise

    {lines, start, end} = @selectLines content, line
    columnIndicator = @columnIndicator column

    if line isnt end
      lines.splice(line - start + 1, 0, columnIndicator)
    else
      lines.push columnIndicator

    promise.resolve("\n#{lines.join '\n'}\n")
    promise

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





