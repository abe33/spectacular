formatters = spectacular.formatters.console

describe 'console formatter', ->
  describe formatters.ErrorStackFormatter, ->
    context 'for a chrome error', ->
      fixture 'errors/chrome.txt', as: 'error'
      fixture 'errors/chrome_formatted.txt', as: 'expected'

      given 'options', -> colors: false
      given 'formatter', -> new formatters.ErrorStackFormatter @error

      subject -> @formatter.format(@options)

      it -> should equal @expected

    context 'for a firefox error', ->
      fixture 'errors/firefox.txt', as: 'error'
      fixture 'errors/firefox_formatted.txt', as: 'expected'

      given 'options', -> colors: false
      given 'formatter', -> new formatters.ErrorStackFormatter @error

      subject -> @formatter.format(@options)

      it -> should equal @expected

  describe formatters.ErrorSourceFormatter, ->
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
        new formatters.ErrorSourceFormatter @options, @filePath, 3, 11

      subject 'promise', -> @formatter.format()

      specify 'the formatted file', (async) ->
        @promise.then (result) =>
          expect(result).to equal @expected
          async.resolve()
        .fail (reason) ->
          async.reject reason

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
        new formatters.ErrorSourceFormatter @options, @filePath, 3, 11

      subject 'promise', -> @formatter.format()

      specify 'the formatted file', (async) ->
        @promise.then (result) =>
          expect(result).to equal @expected
          async.resolve()
        .fail (reason) ->
          async.reject reason

      the 'options.getOriginalSourceFor method', ->
        @options.getOriginalSourceFor.shouldnt haveBeenCalled





