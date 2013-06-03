spectacular.matchers ||= new spectacular.GlobalizableObject
spectacular.matchers.keepContext = false

# Javascript Diff Algorithm
# By John Resig (http://ejohn.org/)
# Modified by Chu Alan "sprite"
#
# Released under the MIT license.
#
# More Info:
# http://ejohn.org/projects/javascript-diff-algorithm/
spectacular.matchers.exist =
  assert: (actual, notText) ->
    @description = "should#{notText} exist"
    @message = "Expected #{actual}#{notText} to exist"

    actual?

spectacular.matchers.have = (count, label) ->
  assert: (actual, notText) ->
    @description = "should#{notText} have #{count} #{label}"

    switch typeof actual
      when 'string'
        label ||= 'chars'
        andOrBut = if notText.length is 0 then actual.length is count else actual.length isnt count
        @description = "should#{notText} have #{count} #{label}"
        @message = "Expected string #{utils.inspect actual}#{notText} to have #{count} #{label} #{utils.andOrBut andOrBut} was #{actual.length}"

        actual.length is count
      when 'object'
        if utils.isArray actual
          andOrBut = if notText.length is 0 then actual.length is count else actual.length isnt count
          label ||= 'items'
          @description = "should#{notText} have #{count} #{label}"
          @message = "Expected array #{utils.inspect actual}#{notText} to have #{count} #{label} #{utils.andOrBut andOrBut} was #{actual.length}"

          actual.length is count
        else
          unless label?
            throw new Error "Undefined label in have matcher"

          @description = "should#{notText} have #{count} #{label}"
          if actual[label]
            if utils.isArray actual[label]
              andOrBut = if notText.length is 0 then actual[label].length is count else actual[label].length isnt count
              @message = "Expected object #{utils.inspect actual}#{notText} to have #{count} #{label} #{utils.andOrBut andOrBut} was #{actual[label].length}"
              actual[label].length is count
            else
              andOrBut = notText.length isnt 0
              @message = "Expected object #{utils.inspect actual}#{notText} to have #{count} #{label} #{utils.andOrBut andOrBut} #{actual[label]} wasn't an array"
              false
          else
            andOrBut = notText.length isnt 0
            @message = "Expected object #{utils.inspect actual}#{notText} to have #{count} #{label} #{utils.andOrBut andOrBut} it didn't have a property named #{label}"
            false
      else
        andOrBut = notText.length isnt 0
        @message = "Expected #{utils.inspect actual}#{notText} to have #{count} #{label} #{utils.andOrBut andOrBut} it don't belong to a type that can be handled"
        false

spectacular.matchers.have.selector = (selector) ->
  assert: (actual, notText) ->
    @description = "should#{notText} have content that match '#{selector}'"

    @message = "Expected '#{actual.html()}'#{notText} to have selector '#{selector}'"
    actual.find(selector).length > 0

spectacular.matchers.be = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be #{value}"
    switch typeof value
      when 'string'
        state = utils.findStateMethodOrProperty actual, value

        if state?
          if typeof actual[state] is 'function'
            result = actual[state]()
            r = if notText.length is 0 then result else not result
            @message = "Expected #{actual}.#{state}()#{notText} to be true #{utils.andOrBut r} was #{actual[state]()}"
          else
            result = actual[state]
            r = if notText.length is 0 then result else not result
            @message = "Expected #{actual}.#{state}#{notText} to be true #{utils.andOrBut r} was #{actual[state]}"

        else
          @message = "Expected #{actual} to be #{value} #{utils.andOrBut notText.length isnt 0} the state can't be found"
          result = false

        result
      when 'number', 'boolean'
        @message = "Expected #{actual}#{notText} to be #{value}"
        actual?.valueOf() is value
      else
        @description = "should#{notText} be #{utils.squeeze utils.inspect value}"
        @message = "Expected #{utils.inspect actual}#{notText} to be #{utils.inspect value}"
        actual is value

spectacular.matchers.equal = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be equal to #{utils.squeeze utils.inspect value}"
    @message = "Expected #{utils.inspect actual}#{notText} to be equal to #{utils.inspect value}"
    utils.compare actual, value, this

spectacular.matchers.match = (re) ->
  assert: (actual, notText) ->
    @description = "should#{notText} match #{re}"
    # The match matcher allow DOMExpression object as value
    if re.match? and re.contained?
      @message = "Expected '#{$.map actual, (e) -> e.outerHTML}'#{notText} to match #{re}"

      re.match actual
    else
      @message = "Expected '#{actual}'#{notText} to match #{re}"

      re.test actual

spectacular.matchers.contains = (values...) ->
  value = values[0]
  assert: (actual, notText) ->
    # The contains matcher allow DOMExpression object as value
    if value.match? and value.contained?
      @description = "should#{notText} contains #{value}"
      @message = "Expected '#{$.map actual, (e) -> e.outerHTML}'#{notText} to contains #{value}"

      value.contained actual

    else
      valuesDescription = utils.literalEnumeration values.map (v) -> utils.inspect v
      @description = "should#{notText} contains #{valuesDescription}"
      @message = "Expected #{utils.inspect actual}#{notText} to contains #{valuesDescription}"

      values.every (v) -> v in actual

spectacular.matchers.throwAnError = (message) ->
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
    result = if message?
      error? and message.test error.message
    else
      error?
    r = if notText.length is 0 then result else not result
    @message = "Expected#{notText} to throw an error#{msg} #{utils.andOrBut r} was #{error}"

    result

  with: (@arguments...) -> this
  inContext: (@context) -> this


spectacular.matchers.haveBeenCalled =
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
      @description = "should be a spy that have been called"
      @message = "Expected a spy but it was #{actual}"
      false

  with: (@arguments...) -> this
