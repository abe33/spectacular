
class spectacular.formatters.console.ResumeFormatter
  constructor: (@runner, @results) ->
    {@options} = @runner
    {@errors, @failures, @skipped, @pending} = @results

  format: ->
    promise = new spectacular.Promise

    res = ''
    res += @formatResume('Errors:', @errors, 'yellow') if @errors.length > 0
    res += @formatResume('Failures:', @failures, 'red') if @failures.length > 0
    res += @formatResume('Skipped:', @skipped, 'magenta') if @skipped.length > 0
    res += @formatResume('Pending:', @pending, 'yellow') if @pending.length > 0

    promise.resolve res

    promise

  formatResume: (desc, array, color) ->
    res = "    #{desc}\n\n"
    res += array.map((e, i) ->
      "      #{i + 1}. #{e.fullDescription}"
    ).join('\n')
    "#{spectacular.utils.colorize res, color, @options.colors}\n\n"
