ErrorStackFormatter = spectacular.formatters.console.ErrorStackFormatter

describe ErrorStackFormatter, ->
  context 'for a chrome error', ->
    fixture 'errors/chrome.txt', as: 'error'
    fixture 'errors/chrome_formatted.txt', as: 'expected'

    given 'options', -> colors: false
    given 'formatter', -> new ErrorStackFormatter @error, @options

    subject -> @formatter.format()

    itBehavesLike 'a formatter'

  context 'for a firefox error', ->
    fixture 'errors/firefox.txt', as: 'error'
    fixture 'errors/firefox_formatted.txt', as: 'expected'

    given 'options', -> colors: false
    given 'formatter', -> new ErrorStackFormatter @error, @options

    subject -> @formatter.format()

    itBehavesLike 'a formatter'
