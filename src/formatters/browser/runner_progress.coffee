
Plurals =
  failure: 'failures'
  errored: 'errored'
  skipped: 'skipped'
  pending: 'pending'
  success: 'success'

class spectacular.widgets.RunnerProgress

  init: (@runner, @reporter) ->
    @container = buildHTML spectacular.templates.progress(seed: @runner.options.seed, chars: CHAR_MAP)

    @totalValue = @container.querySelector('.all .total')
    @timeValue = @container.querySelector('.time .value')
    @allValue = @container.querySelector('.all .value')
    for state of CHAR_MAP
      @[state + 'Value'] = @container.querySelector(".#{state} .value")
      @[state + 'Text'] = @container.querySelector(".#{state} .symbol")

    @reporter.container.appendChild @container

  onStart: ->
    @counters =
      all: 0
      failure: 0
      errored: 0
      skipped: 0
      pending: 0
      success: 0

    @totalValue.textContent = @runner.examples.length
    @interval = setInterval =>
      t = new Date(new Date() - @runner.specsStartedAt)
      @timeValue.textContent = "#{t.getSeconds()}.#{t.getMilliseconds()}s"
    , 100

    self = this
    for state of CHAR_MAP
      btn = @container.querySelector ".#{state}"
      btn.onclick = -> toggleClass document.body, "hide-#{this.attributes['data-state'].value}"

  update: ->
    @allValue.textContent = @counters.all
    for key,c of CHAR_MAP
      @["#{key}Value"].textContent = @counters[key]
      @["#{key}Text"].textContent = ' ' + if @counters[key] > 1 then Plurals[key] else key

      if @counters[key] and not hasClass(@[key], 'not-zero')
        addClass @[key], 'not-zero'

  onResult: (e) ->
    example = e.target
    @counters.all++
    @counters[example.result.state]++

    if example.result.state in ['failure', 'errored']
      addClass @container, 'fail'

    @update()

  onEnd: (e) ->
    clearInterval @interval

    results = e.target

    t = new Date(results.specsEndedAt - results.specsStartedAt)
    @timeValue.textContent = "#{t.getSeconds()}.#{t.getMilliseconds()}s"

    if @counters.failure is 0 and @counters.errored is 0
      addClass @container, 'success'
    else
      addClass @container, 'failure'
