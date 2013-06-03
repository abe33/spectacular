utils = spectacular.utils
class spectacular.BrowserStackReporter extends spectacular.StackReporter
  @reports: 0

  constructor: (@error, @options) ->
    @id = BrowserStackReporter.reports
    BrowserStackReporter.reports += 1

  report: ->
    return '' unless @error.stack

    stack = @error.stack.split('\n').filter (line) -> /( at |@)/g.test line
    line = stack.shift()

    pre = """
      <pre id='pre_#{@id}_source' class='loading'></pre>
      <pre id='pre_#{@id}_stack'>#{utils.escape @formatStack stack}</pre>
    """

    [match, url, e, line, c, column] = /(http:\/\/.*\.(js|coffee)):(\d+)(:(\d+))*/g.exec line

    column = @error.columnNumber + 1 if not column? and @error.columnNumber?

    @getLines(url, parseInt(line), parseInt(column)).then (msg) =>
      source = $("#pre_#{@id}_source")
      source.html(msg).removeClass('loading')
      source.height $("#pre_#{@id}").height()

    pre


class spectacular.BrowserReporter
  STATE_CHARS =
    pending: '*'
    skipped: 'x'
    failure: 'F'
    errored: 'E'
    success: '.'

  constructor: (@options) ->
    @errorsCounter = 1
    @failuresCounter = 1
    @errors = []
    @failures = []
    @skipped = []
    @pending = []
    @results = []
    @examples = []

    @reporter = $("""
      <div id="reporter">
        <header>
          <h1>Spectacular</h1>
          <h2>#{spectacular.version}</h2>
          <pre></pre>
          <p></p>
        </header>
        <section id="controls">#{
          ['success', 'pending', 'errored', 'failure', 'skipped'].map((k) ->
            "<button class='toggle #{k}'>#{k}</button>"
          ).join '\n'
          }
        </section>
        <section id="examples"></section>
        <footer></footer>
      </div>
    """)
    @reporter.find('button.toggle').click (e) ->
      button = $(e.target)
      $('html').toggleClass "hide-#{button.text()}"
      button.toggleClass "off"

    @examplesContainer = @reporter.find '#examples'
    @progress = @reporter.find 'header pre'
    @counters = @reporter.find 'header p'

  onEnd: (event) =>
    runner = event.target
    window.resultReceived = true
    window.result = not @hasFailures()
    if result
      $('html').addClass 'success'
    else
      $('html').addClass 'failure'

    @counters.find('#counters').append ", finished in #{@formatDuration runner.specsStartedAt, runner.specsEndedAt}"

  link: (example, id) ->
    """<a href='#example_#{id}'
          class='#{example.result.state}'
          title='#{example.description}'
       >#{@stateChar example.result.state}</a>
    """

  stateChar: (state) -> STATE_CHARS[state]

  onResult: (event) =>
    example = event.target
    @results.push example.result
    @examples.push example
    @progress.append @link example, @examples.length
    @counters.html @formatCounters()
    switch example.result.state
      when 'pending' then @pending.push example
      when 'skipped' then @skipped.push example
      when 'errored' then @errors.push example
      when 'failure' then @failures.push example


    id = @examples.length
    if example.result.expectations.length > 0
      ex = $ """
        <article class="example preload #{example.result.state}" data-id="#{id}" id="example_#{id}">
          <header>
            <h4>#{example.description}</h4>
            <span class='result'>#{example.result.state}</span>
            <span class='time'><span class='icon-time'></span>#{example.duration / 1000}s</span>
          </header>
          <div class="expectations">
            #{(@formatExpectation e for e in example.result.expectations).join('')}
          </div>
        </article>
      """
    else
      ex = $ """
        <article class="example preload #{example.result.state}" data-id="#{id}" id="example_#{id}">
          <header>
            <h4>#{example.description}</h4>
            <span class='result'>#{example.result.state}</span>
            <span class='time'><span class='icon-time'></span>#{example.duration}s</span>
          </header>
          #{
            if example.reason?
              "<aside>
                <pre>#{utils.escapeDiff example.reason.message}</pre>
                #{ if example.reason? then @traceSource example.reason else ''}
              </aside>"
            else ''
          }
        </article>
      """


    ex.click -> ex.toggleClass 'closed'
    @examplesContainer.append ex
    ex.find('pre:not([id])').each -> $(@).height $(@).height()
    ex.addClass 'closed'
    ex.removeClass 'preload'

  formatExpectation: (expectation) ->
    """
    <div class="expectation #{if expectation.success then 'success' else 'failure'}">
      <h5>#{expectation.description}</h5>
      <pre>#{utils.escapeDiff expectation.message}</pre>
      #{ if expectation.trace? then @traceSource expectation.trace else ''}
    </div>
    """

  traceSource: (error) ->
    (new spectacular.BrowserStackReporter error, @options).report()

  formatCounters: ->
    failures = @failures.length
    errored = @errors.length
    skipped = @skipped.length
    pending = @pending.length
    success = @examples.length - failures - errored - pending - skipped
    assertions = @results.reduce ((a, b) -> a + b.expectations.length), 0
    "<span id='counters'>
    #{@formatResults success, failures, errored, skipped, pending, assertions}
    </span>"

  formatResults: (s, f, e, sk, p, a) ->
    he = f + e
    "#{@formatCount s, 'success', 'success', @toggle he, 'success'},
    #{@formatCount a, 'assertion', 'assertions', @toggle he, 'success'},
    #{@formatCount f, 'failure', 'failures', @toggle he, 'success', 'failure'},
    #{@formatCount e, 'error', 'errors', @toggle e, 'success', 'errored'},
    #{@formatCount sk, 'skipped', 'skipped', @toggle sk, 'success', 'skipped'},
    #{@formatCount p, 'pending', 'pending', @toggle p, 'success', 'pending'}".replace /\s+/g, ' '

  formatCount: (value, singular, plural, color) ->
    s = if value is 0
        plural
      else if value is 1
        singular
      else
        plural

    if color?
      s = "<span class='#{color}'>#{value}</span> #{s}"
    else
      s = "<span>#{value}</span> #{s}"
    s
  toggle: (value, c1, c2) -> if value then c2 else c1

  formatDuration: (start, end) ->
    duration = (end.getTime() - start.getTime()) / 1000
    duration = "<span class='yellow'>#{Math.max 0, duration}s</span>"
    duration

  hasFailures: ->
    @results.some (result) -> result.state in ['failure', 'skipped', 'errored']

  appendToBody: -> $('body').append @reporter

cache = {}
loaders = {}
options.jQuery = $
options.loadFile = (file) ->

  promise = new spectacular.Promise

  if file of cache
    setTimeout (-> promise.resolve cache[file]), 0
    return promise

  if file of loaders
    loaders[file].done (data) -> promise.resolve data
    return promise

  loaders[file] = $.ajax
    url: file
    success: (data) ->
      promise.resolve cache[file] = data
    dataType: 'html'

  promise

spectacular.env = new spectacular.Environment(options)
spectacular.env.globalize()
spectacular.env.runner.loadStartedAt = new Date()
spectacular.env.runner.paths = paths

window.onload = ->
  reporter = new spectacular.BrowserReporter(options)
  reporter.appendToBody()
  spectacular.env.runner.on 'result', reporter.onResult
  spectacular.env.runner.on 'end', reporter.onEnd
  spectacular.env.runner.loadEndedAt = new Date()
  spectacular.env.runner.specsStartedAt = new Date()

  spectacular.env.run().fail (reason) ->
    console.log reason

