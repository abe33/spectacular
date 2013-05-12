
spectacular = spectacular or {}
spectacular.matchers ||= {}

spectacular.matchers.exist =
  assert: (actual, notText) ->
    @description = "should#{notText} exist"
    @message = "Expected #{actual}#{notText} to exist"

    actual?

spectacular.matchers.be = (state) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be #{state}"
    @message =
      "Expected #{actual}.#{state}#{notText}
      to be true but was #{actual[state]}".replace /\s+/g, ' '

    actual[state]

spectacular.matchers.equal = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be equal to #{value}"
    @message = "Expected #{actual}#{notText} to be equal to #{value}"

    actual is value

global[k] = v for k,v of spectacular.matchers
