describe spectacular.ErrorParser, ->
  fixture 'errors/firefox.txt', as: 'firefox'
  fixture 'errors/chrome.txt', as: 'chrome'
  fixture 'errors/node.txt', as: 'node'

  given 'parser', -> new spectacular.ErrorParser @stack

  context 'for a chrome stack', ->
    given 'stack', -> @chrome

    itShould 'match error'

  context 'for a node stack', ->
    given 'stack', -> @node

    itShould 'match error'

  context 'for a firefox stack', ->
    given 'stack', -> @firefox

    itShould 'match error'
