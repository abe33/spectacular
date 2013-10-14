
class spectacular.formatters.console.DurationFormatter
  constructor: (@runner, @results) ->
    {@options} = @runner

  format: ->
    promise = new spectacular.Promise

    {loadStartedAt, loadEndedAt, specsStartedAt, specsEndedAt} = @results

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
