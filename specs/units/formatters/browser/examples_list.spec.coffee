
if typeof module is 'undefined'
  describe spectacular.widgets.ExamplesList, ->
    fixture 'formatters/list.dom', as: 'listDOM'

    given 'list', -> new spectacular.widgets.ExamplesList

    withWidgetSetup ->
      before ->
      spyOn(@reporter, 'errorOccured')
        @list.init @runner, @reporter
        @list.onStart(target: @reporter)


      given 'container', -> @list.container
      given 'all', -> @container.querySelector '.all .value'
      given 'header', -> @container.querySelector '.header'
      given 'listContainer', -> @container.querySelector 'div'

      the -> @container.should match @listDOM

      whenPass ->
        context 'when a result event is propagated', ->
          fixture 'formatters/list_item.dom', as: 'itemDOM'


          context 'for a successful example', ->
            given 'example', -> create 'example', 'successful'

            before -> @list.onResult target: @example

            the 'tests counter', -> @all.textContent.should equal '1'
            the -> @listContainer.should contains @itemDOM

            context

          context 'for a failing example', ->
            given 'example', -> create 'example', 'failure'

            before -> @list.onResult target: @example

            the 'tests counter', -> @all.textContent.should equal '1'
            the -> @listContainer.should contains @itemDOM
            the 'container', -> @reporter.errorOccured.should haveBeenCalled
