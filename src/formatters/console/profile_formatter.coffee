
class spectacular.formatters.console.ProfileFormatter
  constructor: (@runner, @results) ->
    {@examples, @options} = @runner

  format: ->
    promise = new spectacular.Promise

    sortedExamples = @examples.sort((a, b) -> b.duration - a.duration)[0..9]
    totalDuration = @results.specsEndedAt.getTime() - @results.specsStartedAt.getTime()

    topSlowest = sortedExamples.reduce ((a,b) -> a + b.duration), 0
    rate = Math.floor(topSlowest / totalDuration * 10000) / 100

    res = "  Top 10 slowest examples (#{topSlowest / 1000} seconds, #{rate}% of total time)\n\n"
    for example in sortedExamples
      duration = "#{Math.floor(example.duration) / 1000} seconds"
      res += "    #{spectacular.utils.colorize duration, 'red', @options.colors} #{example.fullDescription}\n"

    promise.resolve "#{res}\n"

    promise
