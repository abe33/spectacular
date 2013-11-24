
class spectacular.formatters.console.SeedFormatter
  constructor: (@runner) ->
    {@options} = @runner
    {@seed} = @options

  format: ->
    promise = new spectacular.Promise

    promise.resolve "  Seed #{spectacular.utils.colorize @seed.toString(), 'cyan', @options.colors}\n\n"

    promise
