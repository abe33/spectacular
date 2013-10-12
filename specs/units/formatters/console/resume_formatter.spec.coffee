ResumeFormatter = spectacular.formatters.console.ResumeFormatter

describe ResumeFormatter, ->
  fixture 'formatters/resume.txt', as: 'expected'

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
      pending: [ { fullDescription: 'Pending' } ]
      skipped: [ { fullDescription: 'Skipped' } ]
      errors: [ { fullDescription: 'Errored' } ]
      failures: [ { fullDescription: 'Failed' } ]
    }

  given 'formatter', -> new ResumeFormatter @runner, @results

  subject -> @formatter.format()

  itBehavesLike 'a formatter'


