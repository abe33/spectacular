
class spectacular.BrowserReporter
  constructor: ->
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
          <p></p>
        </header>
        <section id="examples"></section>
        <footer></footer>
      </div>
    """)

    @examples = @reporter.find '#examples'
    @progress = @reporter.find 'header p'

  buildResults: (lstart, lend, sstart, send) ->
    res = '\n\n'
    for result in @results
      switch result.state
        when 'pending' then @pending.push result.example
        when 'skipped' then @skipped.push result.example
        when 'errored'
          @errors.push result.example
          res += result.example.reason + '\n\n'
        when 'failure'
          @failures.push result.example

    res += @formatCounters()
    res += '\n'

  registerResult: (example) ->
    @results.push example.result
    @examples.push example
    @progress.append switch example.result.state
      when 'pending'
        "<a class='pending' href='#example_#{@examples.length}'>*</a>"
      when 'skipped'
        "<a class='skipped' href='#example_#{@examples.length}'>x</a>"
      when 'failure'
        "<a class='failure' href='#example_#{@examples.length}'>F</a>"
      when 'errored'
        "<a class='errored' href='#example_#{@examples.length}'>E</a>"
      when 'success'
        "<a class='success' href='#example_#{@examples.length}'>.</a>"

    if example.result.expectations.length > 0
      @examples.append """
        <article class="example #{example.result.state}" id="example_#{@examples.length}">
          <header>
            <h4>#{example.description}</h4>
          </header>
          <div class="expectations">
            #{@formatExpectation e for e in example.result.expectations}
          </div>
        </article>
      """
    else
      @examples.append """
        <article class="example #{example.result.state}">
          <header>
            <h4>#{example.description}</h4>
          </header>
          <aside>
            <pre>#{example.reason}</pre>
            <pre>#{example.reason?.stack}</pre>
          </aside>
        </article>
      """

  formatExpectation: (expectation) ->
    """
    <div class="expectation">
      <h5>#{expectation.description}</h5>
      <pre>#{expectation.message}</pre>
      <pre>#{expectation.trace?.stack}</pre>
    </div>
    """

  formatCounters: ->
    failures = @failures.length
    errored = @errors.length
    skipped = @skipped.length
    pending = @pending.length
    success = @examples.length - failures - errored - pending - skipped
    assertions = @results.reduce ((a, b) -> a + b.expectations.length), 0
    @formatResults success, failures, errored, skipped, pending, assertions

  formatResults: (s, f, e, sk, p, a) ->
    he = f + e
    "#{@formatCount s, 'success', 'success'}, #{@formatCount a, 'assertion', 'assertions'}, #{@formatCount f, 'failure', 'failures'}, #{@formatCount e, 'error', 'errors'}, #{@formatCount sk, 'skipped', 'skipped'}, #{@formatCount p, 'pending', 'pending'}"

  formatCount: (value, singular, plural) ->
    s = ("#{value} #{
      if value is 0
        plural
      else if value is 1
        singular
      else
        plural
    }")
    s

  hasFailures: ->
    @results.some (result) -> result.state in ['failure', 'skipped', 'errored']

  appendToBody: -> $('body').append @reporter

  printResults: (lstart, lend, sstart, send) ->

# This bootstrap the
unless isCommonJS
  spectacular.env = new spectacular.Environment(
    spectacular.BrowserReporter, options
  )
  spectacular.env.load()
  spectacular.env.runner.loadStartedAt = new Date()
  spectacular.env.runner.paths = paths

  window.onload = ->
    spectacular.env.formatter.appendToBody()
    spectacular.env.runner.loadEndedAt = new Date()
    spectacular.env.runner.specsStartedAt = new Date()

    spectacular.env.run().fail (reason) ->
      console.log reason

