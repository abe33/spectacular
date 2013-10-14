

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
