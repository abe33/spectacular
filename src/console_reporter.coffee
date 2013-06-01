
## StackReporter

class spectacular.StackReporter
  constructor: (@error, @options) ->

  format: ->
    promise = new spectacular.Promise
    if @error.stack?
      stack = @error.stack.split('\n').filter (line) -> /(at|@)/g.test line
      res = '\n'
      if @options.showSource
        @formatErrorInFile(stack[0]).then (msg) =>
          res += msg + @formatStack stack
          res = res.grey unless @options.noColors
          promise.resolve res
      else
        res += @formatStack stack
        res = res.grey unless @options.noColors
        promise.resolve res
    else
      promise.resolve res

    promise

  formatStack: (stack) ->
    if @options.longTrace
      "\n\n#{stack.join '\n'}\n"
    else
      s = "\n#{stack[0..5].join '\n'}"
      s = utils.indent s if /@/.test s
      s += "\n    ...\n\n    use --long-trace option to view the #{stack.length - 6} remaining lines" if stack.length > 6
      s += "\n\n"

  formatErrorInFile: (line) ->
    promise = new spectacular.Promise

    re = /(at.*\(|@)((http:\/\/)?.*\.(js|coffee)):(\d+)(:(\d+))*/
    unless re.test line
      promise.resolve ''
      return promise

    [match, p, file, h, e, line, c, column] = re.exec line
    column = @error.columnNumber + 1 if not column? and @error.columnNumber?

    @getLines(file, parseInt(line), parseInt(column)).then (lines) ->
      promise.resolve "\n#{lines}\n"

    promise

  getLines: (file, line, column) ->
    promise = new spectacular.Promise
    @options.loadFile(file).then (fileContent) =>
      fileContent = fileContent.split('\n').map (l,i) =>
        "    #{utils.padRight i + 1} | #{l}"

      @insertColumnLine fileContent, line, column

      startLine = Math.max(1, line - 3) - 1
      endLine = Math.min(fileContent.length, line + 2) - 1

      lines = fileContent[startLine..endLine].join('\n')
      promise.resolve lines

    promise

  insertColumnLine: (content, line, column) ->
    if line is content.length
      content.push line
    else
      content.splice line, 0, "         | #{utils.padRight('^', column)}"


## ConsoleReporter

class spectacular.ConsoleReporter
  @include spectacular.EventDispatcher

  constructor: (@options) ->
    @errorsCounter = 1
    @failuresCounter = 1
    @errors = []
    @failures = []
    @skipped = []
    @pending = []
    @results = []
    @examples = []

  onResult: (event) =>
    example = event.target
    @printExampleResult example
    @results.push example.result
    @examples.push example
    switch example.result.state
      when 'pending' then @pending.push example
      when 'skipped' then @skipped.push example
      when 'errored' then @errors.push example
      when 'failure' then @failures.push example

  onEnd: (event) =>
    runner = event.target
    @buildResults(
      runner.loadStartedAt,
      runner.loadEndedAt,
      runner.specsStartedAt,
      runner.specsEndedAt
    ).then (report) =>
      @dispatch new spectacular.Event 'report', report

  buildResults: (lstart, lend, sstart, send) ->
    promise = new spectacular.Promise
    res = '\n\n'

    spectacular.Promise.all(@formatResult result for result in @results)
    .then (results) =>
      res += results.filter((s) -> s? and s.length > 0).join '\n'
      res += @formatResume()
      res += @formatProfile(sstart, send) if @options.profile
      res += @formatTimers(lstart, lend, sstart, send)
      res += @formatCounters()
      res += '\n\n'

      promise.resolve res

    promise

  formatResult: (result) =>
    promise = new spectacular.Promise
    switch result.state
      when 'errored'
        @formatExampleError(result.example).then (msg) ->
          promise.resolve msg
      when 'failure'
        if result.expectations.length > 0
          for expectation in result.expectations
            unless expectation.success
              @formatExpectationFailure(expectation).then (msg) ->
                promise.resolve msg
        else
          @formatExampleFailure(result.example).then (msg) ->
            promise.resolve msg
      else
        promise.resolve ''

    promise

  printExampleResult: (example) =>
    res = @formatExampleResult example
    @dispatch new spectacular.Event 'message', res if res?

  formatExampleResult: (example) ->
    if @options.noColors
      switch example.result.state
        when 'pending' then '*'
        when 'skipped' then 'x'
        when 'failure' then 'F'
        when 'errored' then 'E'
        when 'success' then '.'

    else
      switch example.result.state
        when 'pending' then '*'.yellow
        when 'skipped' then 'x'.magenta
        when 'failure' then 'F'.red
        when 'errored' then 'E'.yellow
        when 'success' then '.'.green

  formatStack: (e) ->
    new spectacular.StackReporter(e, @options).format()

  formatExampleFailure: (example) ->
    promise = new spectacular.Promise

    res =  @failureBadge example.description
    @formatError(example.reason).then (msg) ->
      res +=  msg + '\n'
      promise.resolve res

    promise

  formatExpectationFailure: (expectation) ->
    promise = new spectacular.Promise

    res = @failureBadge expectation.fullDescription
    res += '\n'
    res += @formatMessage expectation.message
    if @options.trace
      @formatStack(expectation.trace).then (msg) ->
        res += msg if msg?
        promise.resolve res + '\n'
    else
      promise.resolve res

    promise

  formatExampleError: (example) ->
    promise = new spectacular.Promise

    res =  @errorBadge example.description

    @formatError(example.reason).then (msg) ->
      promise.resolve res + msg

    promise

  formatError: (error) ->
    promise = new spectacular.Promise
    res = @formatMessage error.message

    if @options.trace
      @formatStack(error).then (msg) ->
        promise.resolve res + msg
    else
      promise.resolve res

    promise

  failureBadge: (message) ->
    badge = ' FAIL '
    if @options.noColors
      "#{badge} - #{@failuresCounter++} - #{message}\n"
    else
      "#{badge.inverse.bold} #{@failuresCounter++} #{' '.inverse} #{message}\n".red

  errorBadge: (message) ->
    badge = ' ERROR '
    if @options.noColors
      "#{badge} - #{@errorsCounter++} - #{message}\n"
    else
      "#{badge.inverse.bold} #{@errorsCounter++} #{' '.inverse} #{message}\n".yellow

  formatMessage: (message) -> "\n#{utils.indent message or ''}"

  formatResume: ->
    res = ''
    res += @mapDescription('Errors:', @errors, 'yellow') if @errors.length > 0
    res += @mapDescription('Failures:', @failures, 'red') if @failures.length > 0
    res += @mapDescription('Skipped:', @skipped, 'magenta') if @skipped.length > 0
    res += @mapDescription('Pending:', @pending, 'yellow') if @pending.length > 0
    res

  formatProfile: (specsStartedAt, specsEndedAt) ->
    sortedExamples = @examples.sort((a, b) -> b.duration - a.duration)[0..9]
    totalDuration = specsEndedAt.getTime() - specsStartedAt.getTime()

    topSlowest = sortedExamples.reduce ((a,b) -> a + b.duration), 0
    rate = Math.floor(topSlowest / totalDuration * 10000) / 100

    res = "Top 10 slowest examples (#{topSlowest / 1000} seconds, #{rate}% of total time)\n\n"
    for example in sortedExamples
      duration = "#{Math.floor(example.duration) / 1000} seconds"
      res += "    #{
        if @options.noColors then duration else duration.red
      } #{example.fullDescription}\n"

    "#{res}\n"

  mapDescription: (desc, array, color) ->
    res = "    #{desc}\n\n"
    res += array.map((e, i) ->
      "      #{i + 1}. #{e.fullDescription}"
    ).join('\n')
    res = res[color] unless @options.noColors
    "#{res}\n\n"

  formatTimers: (loadStartedAt, loadEndedAt, specsStartedAt, specsEndedAt) ->
    if loadStartedAt? and loadEndedAt?
      loadDuration = @formatDuration loadStartedAt, loadEndedAt
    specsDuration = @formatDuration specsStartedAt, specsEndedAt

    res = ''
    res += "Specs loaded in #{loadDuration}\n" if loadDuration?
    res += "Finished in #{specsDuration}\n\n"

  formatCounters: ->
    failures = @failures.length
    errored = @errors.length
    skipped = @skipped.length
    pending = @pending.length
    success = @examples.length - failures - errored - pending - skipped
    assertions = @results.reduce ((a, b) -> a + b.expectations.length), 0
    @formatResults success, failures, errored, skipped, pending, assertions

  formatResults: (s, f, e, sk, p, a) ->
    toggle = utils.toggle
    he = f + e
    utils.squeeze("#{@formatCount s, 'success', 'success', toggle he, 'green'},
    #{@formatCount a, 'assertion', 'assertions', toggle he, 'green'},
    #{@formatCount f, 'failure', 'failures', toggle he, 'green', 'red'},
    #{@formatCount e, 'error', 'errors', toggle e, 'green', 'yellow'},
    #{@formatCount sk, 'skipped', 'skipped', toggle sk, 'green', 'magenta'},
    #{@formatCount p, 'pending', 'pending', toggle p, 'green', 'yellow'}")

  formatDuration: (start, end) ->
    duration = (end.getTime() - start.getTime()) / 1000
    duration = "#{Math.max 0, duration}s"
    duration = duration.yellow unless @options.noColors
    duration

  formatCount: (value, singular, plural, color) ->
    s = ("#{value} #{
      if value is 0
        plural
      else if value is 1
        singular
      else
        plural
    }")
    s = s[color] if color? and not @options.noColors
    s


