ResultsFormatter = spectacular.formatters.console.ResultsFormatter

describe ResultsFormatter, ->
  fixture 'formatters/results.txt', as: 'expected'

  given 'options', ->
    {
      colors: false
    }

  given 'results', ->
    {
      results: []
      errors: []
      failures: []
      skipped: []
      pending: []
    }

  given 'runner', ->
    {
      examples: []
      options: @options
    }

  given 'formatter', -> new ResultsFormatter @runner, @results

  subject -> @formatter.format()

  itBehavesLike 'a formatter'
