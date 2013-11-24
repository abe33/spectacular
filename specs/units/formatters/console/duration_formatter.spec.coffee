DurationFormatter = spectacular.formatters.console.DurationFormatter

describe DurationFormatter, ->
  fixture 'formatters/duration.txt', as: 'expected'

  given 'options', ->
    {
      colors: false
    }

  given 'runner', ->
    {
      options: @options
    }

  given 'results', ->
    {
      loadStartedAt: { getTime: -> 0 }
      loadEndedAt: { getTime: -> 2 }
      specsStartedAt: { getTime: -> 0 }
      specsEndedAt: { getTime: -> 4 }
    }

  given 'formatter', -> new DurationFormatter @runner, @results

  subject -> @formatter.format()

  itBehavesLike 'a formatter'

