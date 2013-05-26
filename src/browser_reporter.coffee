class spectacular.StackReporter
  @reports: 0
  @files: {}
  @filesLoader: {}

  constructor: (@error, @options) ->
    @id = StackReporter.reports
    StackReporter.reports += 1

  report: ->
    return '' unless @error.stack
    pre = "<pre id='pre_#{@id}' class='loading'></pre>"
    stack = @error.stack.split('\n').filter (line) -> /( at |@)/g.test line
    line = stack.shift()
    [match, url, e, line, c, column] = /(http:\/\/.*\.(js|coffee)):(\d+)(:(\d+))*/g.exec line

    @options.loadFile(url).then (data) =>
      $("#pre_#{@id}").html(@getLines data, line, column).removeClass 'loading'

    pre

  getLines: (fileContent, line, column) ->
    line = parseInt line
    fileContent = fileContent.split('\n').map (l,i) =>
      " #{@padRight i + 1} | #{l}"

    @insertColumnLine fileContent, line, column if column?

    startLine = Math.max(1, line - 3) - 1
    endLine = Math.min(fileContent.length, line + 2) - 1
    fileContent[line-1] = "<span class='line'>#{fileContent[line-1]}</span>"
    lines = fileContent[startLine..endLine].join('\n')
    lines

  insertColumnLine: (content, line, column) ->
    column = parseInt column
    if line is content.length
      content.push line
    else
      content.splice line, 0, "      |#{@padRight('^', column)}"

  padRight: (string, pad=4) ->
    string = string.toString()
    string = " #{string}" while string.length < pad
    string


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

        }</section>
        <section id="examples"></section>
        <footer></footer>
      </div>
    """)
    @reporter.find('button').click (e) ->
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

    if example.result.expectations.length > 0
      ex = $ """
        <article class="example #{example.result.state}" id="example_#{@examples.length}">
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
        <article class="example #{example.result.state}" id="example_#{@examples.length}">
          <header>
            <h4>#{example.description}</h4>
            <span class='result'>#{example.result.state}</span>
            <span class='time'><span class='icon-time'></span>#{example.duration}s</span>
          </header>
          <aside>
            <pre>#{example.reason.message}</pre>
            #{ if example.reason? then @traceSource example.reason else ''}
            <pre>#{example.reason?.stack}</pre>
          </aside>
        </article>
      """

    ex.click -> ex.toggleClass 'open'
    @examplesContainer.append ex

  formatExpectation: (expectation) ->
    """
    <div class="expectation #{if expectation.success then 'success' else 'failure'}">
      <h5>#{expectation.description}</h5>
      <pre>#{expectation.message}</pre>
      #{ if expectation.trace? then @traceSource expectation.trace else ''}
      <pre>#{expectation.trace?.stack}</pre>
    </div>
    """

  traceSource: (error) ->
    (new spectacular.StackReporter error, @options).report()

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


# This bootstrap the
unless isCommonJS
  options.loadFile = (file) ->
    promise = new spectacular.Promise
    $.ajax
      url: file
      success: (data) -> promise.resolve data
      dataType: 'html'

    promise

  spectacular.env = new spectacular.Environment(options)
  spectacular.env.load()
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

