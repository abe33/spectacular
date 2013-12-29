describe spectacular.errors.ErrorParser, ->
  fixture 'errors/firefox.txt', as: 'firefox'
  fixture 'errors/chrome.txt', as: 'chrome'
  fixture 'errors/node.txt', as: 'node'

  given 'parser', -> new spectacular.errors.ErrorParser @stack

  context 'for a chrome stack', ->
    given 'stack', -> @chrome

    itShould 'match error'

  context 'for a node stack', ->
    given 'stack', -> @node

    itShould 'match error'

  context 'for a firefox stack', ->
    given 'stack', -> @firefox

    itShould 'match error'

  context 'for a native error', ->
    fixture 'errors/firefox_native.txt', as: 'firefox'
    fixture 'errors/chrome_native.txt', as: 'chrome'
    fixture 'errors/node_native.txt', as: 'node'

    context 'for a chrome stack', ->
      given 'stack', -> @chrome

      the -> @parser.should exist
      the -> @parser.details(@parser.lines[0]).native.should be true

    context 'for a node stack', ->
      given 'stack', -> @node

      the -> @parser.should exist
      the -> @parser.details(@parser.lines[0]).native.should be true

    context 'for a firefox stack', ->
      given 'stack', -> @firefox

      the -> @parser.should exist
      the -> @parser.details(@parser.lines[0]).line.should equal '37'


  context 'with an error raised in an accessor', ->

    fixture 'errors/firefox_accessor.txt', as: 'firefox'
    fixture 'errors/chrome_accessor.txt', as: 'chrome'
    fixture 'errors/node_accessor.txt', as: 'node'

    context 'for a chrome stack', ->
      given 'stack', -> @chrome

      the -> @parser.should exist
      the -> @parser.details(@parser.lines[0]).line.should equal '83'
    context 'for a node stack', ->
      given 'stack', -> @node

      the -> @parser.should exist
      the -> @parser.details(@parser.lines[0]).line.should equal '83'

    context 'for a firefox stack', ->
      given 'stack', -> @firefox

      the -> @parser.should exist
      the -> @parser.details(@parser.lines[0]).line.should equal '83'


