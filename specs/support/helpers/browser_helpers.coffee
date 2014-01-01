if typeof module is 'undefined'
  fixture 'formatters/reporter.html', as: 'reporterContainer'

  spectacular.helper 'withWidgetSetup', (block) ->
    given 'reporter', ->
      container: @reporterContainer[0]
      widgets: []
      openDetails: ->
      errorOccured: ->

    given 'runner', ->
      examples: []
      options: spectacular.options

    block.call(this)
