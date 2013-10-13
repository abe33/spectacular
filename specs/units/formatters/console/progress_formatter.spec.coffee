ProgressFormatter = spectacular.formatters.console.ProgressFormatter

describe ProgressFormatter, ->
  given 'options', ->
    {
      colors: false
    }
  given 'example', ->
    {
      result: @result
    }

  given 'formatter', -> new ProgressFormatter @example, @options

  subject -> @formatter.format()

  context 'for a succeeding example', ->
    given 'result', -> state: 'success'

    it -> should equal '.'

  context 'for a failing example', ->
    given 'result', -> state: 'failure'

    it -> should equal 'F'

  context 'for an errored example', ->
    given 'result', -> state: 'errored'

    it -> should equal 'E'

  context 'for a pending example', ->
    given 'result', -> state: 'pending'

    it -> should equal '*'

  context 'for a skipped example', ->
    given 'result', -> state: 'skipped'

    it -> should equal 'x'
