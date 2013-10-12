
ErrorSourceFormatter = spectacular.formatters.console.ErrorSourceFormatter

describe ErrorSourceFormatter, ->
  fixture 'errors/source_formatted.txt', as: 'expected'
  fixture 'errors/source.txt', as: 'source'

  context 'when the file has a source map', ->
    given 'filePath', -> fixturePath 'errors/source.coffee'
    given 'options', ->
      source = @source

      {
        hasSourceMap: -> true
        getOriginalSourceFor: (file, line, column) ->
          promise = new spectacular.Promise
          promise.resolve({content: source, line, column})
          promise
      }

    given 'formatter', ->
      new ErrorSourceFormatter @options, @filePath, '3', '11'

    subject 'promise', -> @formatter.format()

    itBehavesLike 'a formatter'

  context 'when the file does not have a source map', ->
    given 'filePath', -> fixturePath 'errors/source.js'
    given 'options', ->
      source = @source

      {
        hasSourceMap: -> false
        getOriginalSourceFor: (file, line, column) ->

        loadFile: ->
          promise = new spectacular.Promise
          promise.resolve(source)
          promise
      }

    before ->
      spyOn @options.getOriginalSourceFor

    given 'formatter', ->
      new ErrorSourceFormatter @options, @filePath, '3', '11'

    subject 'promise', -> @formatter.format()

    itBehavesLike 'a formatter'

    the 'options.getOriginalSourceFor method', ->
      @options.getOriginalSourceFor.shouldnt haveBeenCalled
