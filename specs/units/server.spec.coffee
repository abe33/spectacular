if typeof window isnt 'undefined' and window.options?.server
  describe 'the server', ->
    describe 'when the source option have been used', ->
      specify 'the sources content', ->
        expect(window.SourceFileContent).to exist
