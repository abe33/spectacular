ExampleResultsFormatter = spectacular.formatters.console.ExampleResultsFormatter

describe ExampleResultsFormatter, ->
  fixture 'errors/source.txt', as: 'source'

  given 'options', ->
    source = @source
    {
      colors: false
      trace: true
      showSource: true
      hasSourceMap: -> false
      loadFile: -> spectacular.Promise.unit(source)
    }

  given 'formatter', -> new ExampleResultsFormatter @example, @options, 1

  describe '::badge', ->
    subject -> @formatter.badge 'Some message', 'fail', 'red'

    it -> should equal ' FAIL  1   Some message'

  context 'when the example is errored', ->
    fixture 'formatters/example_errored.txt', as: 'template'

    given 'filePath', -> "#{fixturePath 'errors/source.coffee'}:3:11"
    given 'expected', -> @template.replace /\#\{file\}/g, @filePath

    given 'example', ->
      {
        fullDescription: 'Some errored test'
        result:
          state: 'errored'
        reason:
          message: 'Some Error Message'
          stack: """
            Some Error Message
                at Object.<anonymous> (#{@filePath})
                at String.foo (file.js:10:100)
          """
      }

    subject -> @formatter.format()

    itBehavesLike 'a formatter'

  context 'when the example has failed assertions', ->
    fixture 'formatters/example_failed.txt', as: 'template'

    given 'filePath', -> "#{fixturePath 'errors/source.coffee'}:3:11"
    given 'expected', -> @template.replace /\#\{file\}/g, @filePath

    given 'example', ->
      {
        result:
          state: 'failure'
          expectations: [
            {
              success: true
            },
            {
              success: false
              fullDescription: 'Some failing test should have succeed'
              message: 'Expected failing test to have succeed'
              trace:
                stack: """
                  Some Error Message
                      at Object.<anonymous> (#{@filePath})
                      at String.foo (file.js:10:100)
                """
            }
          ]
      }

    subject -> @formatter.format()

    itBehavesLike 'a formatter'

