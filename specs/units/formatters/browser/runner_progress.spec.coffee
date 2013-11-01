if typeof module is 'undefined'
  only describe spectacular.widgets.RunnerProgress, ->
    fixture 'formatters/progress.dom', as: 'progressDOM'

    given 'progress', -> new spectacular.widgets.RunnerProgress

    withWidgetSetup ->
      before ->
        @progress.init @runner, @reporter
        @progress.onStart(target: @reporter)

      given 'container', -> @progress.container
      given 'all', -> @container.querySelector '.all .value'
      given 'success', -> @container.querySelector '.success .value'
      given 'failure', -> @container.querySelector '.failure .value'

      the -> @container.should match @progressDOM

      whenPass ->
        context 'when a result event is propagated', ->

          context 'for a successful example', ->
            given 'example', -> create 'example', 'successful'

            before -> @progress.onResult target: @example

            the 'tests counter', -> @all.textContent.should equal '1'
            the 'success counter', -> @success.textContent.should equal '1'

          context 'for a failing example', ->
            given 'example', -> create 'example', 'failure'

            before -> @progress.onResult target: @example

            the 'tests counter', -> @all.textContent.should equal '1'
            the 'success counter', -> @failure.textContent.should equal '1'

