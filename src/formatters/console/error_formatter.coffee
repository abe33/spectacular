

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
