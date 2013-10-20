
class spectacular.widgets.RunnerProgress
  init: (@runner) ->
    @container = tag 'div', id: 'progress', =>
      @progress = tag 'span'

    document.body.appendChild @container

  onStart: ->
    @counters =
      all: 0
      failure: 0
      errored: 0
      skipped: 0
      pending: 0
      success: 0

    @total = @runner.examples.length
    @interval = setInterval =>
      t = new Date(new Date() - @runner.specsStartedAt)
      @timeValue.textContent = "#{t.getSeconds()}.#{t.getMilliseconds()}s"
    , 100

    inner = []
    inner.push tag 'span', class: 'seed', =>
      icon('random').outerHTML +
      ' ' +
      tag('span', String(@runner.options.seed), class: 'value').outerHTML

    inner.push tag 'span', class: 'time', =>
      icon('time').outerHTML +
      ' ' +
      tag('span', '0', class: 'value').outerHTML

    inner.push tag 'span', class: 'all', =>
      tag('span', '0', class: 'value').outerHTML +
      '/' +
      tag('span', String(@total), class: 'total').outerHTML

    for key,c of CHAR_MAP
      continue if key is 'success'

      inner.push @[key] = tag 'span', class: key, =>
        tag('span', '0', class: 'value').outerHTML +
        tag('span', c, class: 'symbol').outerHTML

    @progress.innerHTML = inner.map((e) -> e.outerHTML).join '\n'

    @timeValue = @progress.querySelector '.time .value'
    @allValue = @progress.querySelector '.all .value'

    for key of CHAR_MAP
      @[key] = @progress.querySelector ".#{key}"
      @[key + "Value"] = @progress.querySelector ".#{key} .value"

  update: ->
    @allValue.textContent = @counters.all
    for key,c of CHAR_MAP
      continue if key is 'success'

      @["#{key}Value"].textContent = @counters[key]

      if @counters[key] and not hasClass(@[key], 'not-zero')
        addClass @[key], 'not-zero'

  onResult: (e) ->
    example = e.target
    @counters.all++
    @counters[example.result.state]++

    if example.result.state in ['failure', 'errored']
      addClass @container, 'fail'

    @update()

  onEnd: (results) ->
    clearInterval @interval
    if @counters.failure is 0 and @counters.errored is 0
      addClass @container, 'success'
    else
      addClass @container, 'failure'
