
class spectacular.formatters.console.ProgressFormatter
  constructor: (@example, @options) ->

  format: ->
    state = @example.result.state
    spectacular.utils.colorize CHAR_MAP[state], COLOR_MAP[state], @options.colors
