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
      given 'errored', -> @container.querySelector '.errored .value'
      given 'failureText', -> @container.querySelector '.failure .symbol'

      the -> @container.should match @progressDOM

      whenPass ->
        context 'when a result event is propagated', ->

          context 'for a successful example', ->
            given 'example', -> create 'example', 'successful'

            before -> @progress.onResult target: @example

            the 'tests counter', -> @all.textContent.should equal '1'
            the 'success counter', -> @success.textContent.should equal '1'

            whenPass ->
              context 'when the end event is propagated', ->
                before -> @progress.onEnd target: @reporter

                the 'container', -> @container.getAttribute('class').should match /success/

          context 'for a failing example', ->
            given 'example', -> create 'example', 'failure'

            before -> @progress.onResult target: @example

            the 'tests counter', -> @all.textContent.should equal '1'
            the 'failure counter', -> @failure.textContent.should equal '1'
            the 'container class', -> @container.getAttribute('class').should match /fail/

            whenPass ->
              context 'when the end event is propagated', ->
                before -> @progress.onEnd target: @reporter

                the 'container', -> @container.getAttribute('class').should match /failure/

              context 'with a second failure', ->
                before -> @progress.onResult target: @example

                the 'tests counter', -> @all.textContent.should equal '2'
                the 'failure counter', -> @failure.textContent.should equal '2'
                the 'failure symbol', -> @failureText.textContent.should equal ' failures'

          context 'for an errored example', ->
            given 'example', -> create 'example', 'errored'

            before -> @progress.onResult target: @example

            the 'tests counter', -> @all.textContent.should equal '1'
            the 'errored counter', -> @errored.textContent.should equal '1'
            the 'container class', -> @container.getAttribute('class').should match /fail/

            whenPass ->
              context 'when the end event is propagated', ->
                before -> @progress.onEnd target: @reporter

                the 'container', -> @container.getAttribute('class').should match /failure/


