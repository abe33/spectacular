
class spectacular.widgets.ExamplesSearch
  init: (@runner, @reporter) ->
    @container = buildHTML spectacular.templates.search()
    @form = @container.querySelector('form')
    @input = @container.querySelector('input')
    @style = @container.querySelector('style')
    @reporter.container.querySelector('#examples header')?.appendChild @container

    @form.onsubmit = =>
      try
        value = spectacular.utils.strip @input.value
        if value is ''
          @style.innerHTML = ''
        else
          @style.innerHTML = "[data-index]:not([data-index*=\"#{value.toLowerCase()}\"]) { display: none; }"
      catch e
        console.log e
        console.log e.stack
      false

  onStart: (e) ->
  onResult: (e) ->
  onEnd: (e) ->


