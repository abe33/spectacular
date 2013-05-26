isCommonJS = typeof window is "undefined"

exports = window unless isCommonJS

# Javascript Diff Algorithm
# By John Resig (http://ejohn.org/)
# Modified by Chu Alan "sprite"
#
# Released under the MIT license.
#
# More Info:
# http://ejohn.org/projects/javascript-diff-algorithm/
utils = spectacular.utils
exports.exist =
  assert: (actual, notText) ->
    @description = "should#{notText} exist"
    @message = "Expected #{actual}#{notText} to exist"

    actual?

exports.be = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be #{value}"
    switch typeof value
      when 'string'
        state = utils.findStateMethodOrProperty actual, value

        if state?
          @message = "Expected #{actual}.#{state}#{notText} to be true but was #{actual[value]}"
          result = if typeof actual[state] is 'function'
            actual[state]()
          else
            actual[state]

        else
          @message = "Expected #{actual} to be #{value} but the state can't be found"
          result = false

        result
      when 'number', 'boolean'
        @message = "Expected #{actual}#{notText} to be #{value}"
        actual.valueOf() is value
      else
        @description = "should#{notText} be #{utils.squeeze utils.inspect value}"
        @message = "Expected #{utils.inspect actual}#{notText} to be #{utils.inspect value}"
        actual is value

exports.equal = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be equal to #{utils.squeeze utils.inspect value}"
    @message = "Expected #{utils.inspect actual}#{notText} to be equal to #{utils.inspect value}"
    utils.compare actual, value, this

exports.match = (re) ->
  assert: (actual, notText) ->
    @description = "should#{notText} match #{re}"
    @message = "Expected '#{actual}'#{notText} to match #{re}"

    re.test actual

exports.throwAnError = (message) ->
  assert: (actual, notText) ->
    msg = if message? then " with message #{message}" else ''
    msg += " with arguments #{utils.inspect @arguments}" if @arguments?

    @description = "should#{notText} throw an error#{msg}"

    try
      if @arguments?
        actual.apply @context, @arguments
      else
        actual.call @context
    catch error
    @message = "Expected#{notText} to throw an error#{msg} but was #{error}"
    if message?
      error? and message.test error.message
    else
      error?

  with: (@arguments...) -> this
  inContext: (@context) -> this


exports.haveBeenCalled =
  assert: (actual, notText) ->
    if typeof actual?.spied is 'function'
      if @arguments?
        @description = "should have been called with #{utils.inspect @arguments}"
        @message = "Expected #{actual.spied}#{notText} to have been called with #{utils.inspect @arguments} but was called with #{actual.argsForCall}"

        actual.argsForCall.length > 0 and actual.argsForCall.some (a) =>
          equal(a).assert(@arguments, '')
      else
        @description = "should have been called"
        @message = "Expected #{actual.spied}#{notText} to have been called"
        actual.argsForCall.length > 0
    else
      @message = "Expected a spy but it was #{actual}"
      false

  with: (@arguments...) -> this

