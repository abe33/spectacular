

class spectacular.formatters.console.ErrorFormatter
  constructor: (@error, @options) ->

  format: ->
    promise = new spectacular.Promise
    formatters = spectacular.formatters.console

    res = @formatMessage @error.message
    res += '\n'

    if @error.stack?
      stackFormatter = new formatters.ErrorStackFormatter @error.stack, @options

      if @options.showSource
        {file, line, column} = stackFormatter.parser.details(stackFormatter.parser.lines[0])

        if file?
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
          stackFormatter
          .format()
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
      promise.resolve res + '\n'

    promise

  formatMessage: (message) -> "\n#{spectacular.utils.indent message or ''}"
