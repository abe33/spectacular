page = require('webpage').create()
system = require('system')

PORT = system.args[1] or 5000

URL = "http://localhost:#{PORT}"

page.onConsoleMessage = (msg, line, source) -> console.log msg

squeeze = (str) -> str.replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, '')

page.open URL, (status) ->
  page.onLoadFinished = ->

  if status isnt 'success'
    console.log JSON.stringify({ error: "Unable to access Spectacular specs at #{URL}" })
    phantom.exit()
  else
    runnerAvailable = page.evaluate -> window.spectacular

    if runnerAvailable
      page.evaluate ->
        styles = {
          # styles
          bold: ['\x1B[1m', '\x1B[22m']
          italic: ['\x1B[3m', '\x1B[23m']
          underline: ['\x1B[4m', '\x1B[24m']
          inverse: ['\x1B[7m', '\x1B[27m']
          strikethrough: ['\x1B[9m', '\x1B[29m']
          # grayscale
          white: ['\x1B[37m', '\x1B[39m']
          grey: ['\x1B[90m', '\x1B[39m']
          black: ['\x1B[30m', '\x1B[39m']
          # colors
          blue: ['\x1B[34m', '\x1B[39m']
          cyan: ['\x1B[36m', '\x1B[39m']
          green: ['\x1B[32m', '\x1B[39m']
          magenta: ['\x1B[35m', '\x1B[39m']
          red: ['\x1B[31m', '\x1B[39m']
          yellow: ['\x1B[33m', '\x1B[39m']
        }
        (k for k of styles).forEach (key) ->
          Object.defineProperty String.prototype, key,
            get: -> styles[key][0] + this + styles[key][1]

        reporter = new window.spectacular.ConsoleReporter(spectacular.options)
        window.env.runner.on 'result', reporter.onResult
        window.env.runner.on 'end', reporter.onEnd
        reporter.on 'report', (msg) -> window.consoleResults = msg.target
        reporter.on 'message', (msg) ->
          window.consoleProgress ||= ''
          window.consoleProgress += msg.target

      done = ->
        result = page.evaluate -> window.result

        console.log squeeze page.evaluate -> window.consoleProgress
        console.log page.evaluate -> window.consoleResults

        if result
          phantom.exit(0)
        else
          phantom.exit(1)

      waitFor specsReady, done
    else
      phantom.exit(1)

specsReady = ->
  page.evaluate -> window.resultReceived and window.consoleResults?

# Wait until the test condition is true or a timeout occurs.
#
# @param [Function] test the test that returns true if condition is met
# @param [Function] ready the action when the condition is fulfilled
# @param [Number] timeout the max amount of time to wait in milliseconds
#
waitFor = (test, ready, timeout = 60000) ->
    start = new Date().getTime()
    condition = false

    wait = ->
      if (new Date().getTime() - start < timeout) and not condition
        condition = test()
      else
        if condition
          ready()
          clearInterval interval

        else
          console.log 'error with timeout'
          phantom.exit(1)

    interval = setInterval wait, 250
