SeedFormatter = spectacular.formatters.console.SeedFormatter

describe SeedFormatter, ->
  fixture 'formatters/seed.txt', as: 'expected'

  given 'options', ->
    {
      seed: 123456789
      colors: false
    }

  given 'runner', -> options: @options

  given 'formatter', -> new SeedFormatter @runner

  subject -> @formatter.format()

  itBehavesLike 'a formatter'
