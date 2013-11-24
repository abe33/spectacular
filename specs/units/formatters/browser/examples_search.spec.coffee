
if typeof module is 'undefined'
  describe spectacular.widgets.ExamplesSearch, ->
    fixture 'formatters/search.dom', as: 'searchDOM'

    given 'search', -> new spectacular.widgets.ExamplesSearch

    withWidgetSetup ->
      before ->
        @search.init @runner, @reporter
        @search.onStart(target: @reporter)

      given 'container', -> @search.container
      given 'form', -> @container.querySelector 'form'
      given 'input', -> @container.querySelector 'input'
      given 'button', -> @container.querySelector 'button'
      given 'style', -> @container.querySelector 'style'

      the -> @container.should match @searchDOM

      whenPass ->
        context 'when the form is submitted', ->
          context 'with a value in the input', ->
            before ->
              @input.setAttribute 'value', 'foo'
              @form.onsubmit()

            specify 'the style node content', ->
              @style.innerHTML.should match '[data-index]:not([data-index*="foo"]) { display: none; }'

          context 'with a value in the input', ->
            before ->
              @form.onsubmit()

            specify 'the style node content', ->
              @style.innerHTML.should equal ''

