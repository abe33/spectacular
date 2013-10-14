
class spectacular.formatters.console.ResultsFormatter
  constructor: (@runner, @results) ->
    {@options} = @runner
    {@errors, @failures, @skipped, @pending, @results} = @results

  format: ->
    promise = new spectacular.Promise

    failures = @failures.length
    errored = @errors.length
    skipped = @skipped.length
    pending = @pending.length
    success = @runner.examples.length - failures - errored - pending - skipped
    assertions = @results.reduce ((a, b) -> a + b.expectations.length), 0

    promise.resolve @formatResults success, failures, errored, skipped, pending, assertions

    promise

  formatResults: (success, failures, errors, skipped, pending, assertions) ->
    toggle = spectacular.utils.toggle
    hasError = failures + errors

    res = []
    res.push @formatCount success, 'success', 'success', toggle hasError, 'green'
    res.push @formatCount assertions, 'assertion', 'assertions', toggle hasError, 'green'
    res.push @formatCount failures, 'failure', 'failures', toggle hasError, 'green', 'red'
    res.push @formatCount errors, 'error', 'errors', toggle errors, 'green', 'yellow'
    res.push @formatCount skipped, 'skipped', 'skipped', toggle skipped, 'green', 'magenta'
    res.push @formatCount pending, 'pending', 'pending', toggle pending, 'green', 'yellow'

    "  #{res.join ', '}\n"

  formatCount: (value, singular, plural, color) ->
    s = ("#{value} #{
      if value is 0
        plural
      else if value is 1
        singular
      else
        plural
    }")
    s = spectacular.utils.colorize s, color, @options.colors if color?
    s
