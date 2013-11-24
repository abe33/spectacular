
ProfileFormatter = spectacular.formatters.console.ProfileFormatter

describe ProfileFormatter, ->
  fixture 'formatters/profile.txt', as: 'expected'

  given 'examples', ->
    [
      { duration: 1, fullDescription: 'ProfileFormatter' }
      { duration: 2, fullDescription: 'ProfileFormatter' }
      { duration: 3, fullDescription: 'ProfileFormatter' }
    ]

  given 'options', ->
    {
      colors: false
    }

  given 'runner', ->
    {
      examples: @examples
      options: @options
    }

  given 'results', ->
    {
      specsStartedAt: { getTime: -> 0 }
      specsEndedAt: { getTime: -> 6 }
    }

  given 'formatter', -> new ProfileFormatter @runner, @results

  subject -> @formatter.format()

  itBehavesLike 'a formatter'
