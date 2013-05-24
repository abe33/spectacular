page = require('webpage').create()

URL = 'http://localhost:5000'

page.onConsoleMessage = (msg, line, source) ->
  console.log msg

squeeze = (str) -> str.replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, '')

page.open URL, (status) ->
  page.onLoadFinished = ->

  if status isnt 'success'
    console.log JSON.stringify({ error: "Unable to access Spectacular specs at #{URL}" })
    phantom.exit()
  else
    runnerAvailable = page.evaluate -> window.spectacular

    if runnerAvailable
      done = ->
        result = page.evaluate -> window.result

        console.log page.evaluate -> $("#examples .example.errored, #examples .example.failure").text()

        console.log squeeze page.evaluate -> $("#reporter header pre").text()
        console.log squeeze page.evaluate -> $("#reporter header p").text()

        if result
          console.log 'specs succeed'
          phantom.exit(0)
        else
          console.log 'specs failed'
          phantom.exit(1)

      waitFor specsReady, done
    else
      phantom.exit(1)

specsReady = ->
  page.evaluate -> window.resultReceived

# Wait until the test condition is true or a timeout occurs.
#
# @param [Function] test the test that returns true if condition is met
# @param [Function] ready the action when the condition is fulfilled
# @param [Number] timeout the max amount of time to wait in milliseconds
#
waitFor = (test, ready, timeout = 10000) ->
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
