
class spectacular.formatters.console.ErrorStackFormatter
  constructor: (@stack, @options) ->
    @parser = new spectacular.errors.ErrorParser @stack

  format: () ->
    promise = new spectacular.Promise

    lines = @parser.lines
    lines = lines.map (line) -> line.replace /^\s*/, '    '

    unless @options.longTrace
      l = lines.length
      lines = lines[0..5]
      l = l - lines.length
      if l isnt 0
        lines.push "\n    use the --long-trace option to view the #{l} remaining lines"

    stack = "\n#{lines.join '\n'}\n\n"
    promise.resolve spectacular.utils.colorize stack, 'grey', @options.colors

    promise
