
if typeof module is 'undefined'
  describe spectacular.widgets.ExampleViewer, ->
    fixture 'formatters/viewer.dom', as: 'viewerDOM'

    given 'viewer', -> new spectacular.widgets.ExampleViewer

    withWidgetSetup ->
      before ->
        @viewer.init @runner, @reporter
        @viewer.onStart(target: @reporter)

    given 'container', -> @viewer.container

    the -> @container.should match @viewerDOM

    whenPass ->
      describe '#displayCard', ->
        fixture 'formatters/card.dom', as: 'cardDom'

        context 'when called with a failing example', ->
          given 'example', -> create 'example', 'failure'

          before -> @viewer.displayCard @example

          the -> @container.should contains @cardDom


