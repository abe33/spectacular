sharedExample 'match error', ->
  describe 'the parser', ->
    the -> @parser.should exist

    the 'size', -> @parser.size.should equal 4

    describe '::find', ->
      context 'with a file path', ->
        subject -> @parser.find 'file.js'

        it -> should have 2, 'lines'

    describe '::details', ->
      context 'with a line from the stack', ->
        subject ->
          line = @parser.find('file.js')[0]
          @parser.details line

        its 'line', -> should equal '10'
        its 'file', -> should equal 'file.js'
        its 'method', -> should equal 'failingFunction'
