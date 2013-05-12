
exports.exist =
  assert: (actual, notText) ->
    @description = "should#{notText} exist"
    @message = "Expected #{actual}#{notText} to exist"

    actual?

exports.be = (state) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be #{state}"
    @message =
      "Expected #{actual}.#{state}#{notText}
      to be true but was #{actual[state]}".replace /\s+/g, ' '

    actual[state]

exports.compare = (actual, value, matcher, noMessage=false) ->
  if typeof actual is 'object'
      if Object::toString.call(actual) is '[object Array]'
        for v,i in actual
          unless exports.compare v, value[i], true
            return false
      else
        for k,v in actual
          unless exports.compare v, value[k], true
            return false
    else
      actual is value

exports.equal = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be equal to #{value}"
    @message = "Expected #{actual}#{notText} to be equal to #{value}"

    exports.compare actual, value, this
