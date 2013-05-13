deef = require 'deep-diff'
diff = require 'node-diff'
util = require 'util'

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

objectDiff = (left, right) -> 'diff'
stringDiff = (left, right) -> 'diff'

compare = (actual, value, matcher, noMessage=false) ->
  switch typeof actual
    when 'object'
      if Object::toString.call(actual) is '[object Array]'
        for v,i in actual
          unless compare v, value[i], matcher, true
            unless noMessage
              matcher.message = "#{matcher.message}\n\n#{objectDiff v, value[i]}"
            return false
        return true
      else
        for k,v of actual
          unless compare v, value[k], matcher, true
            unless noMessage
              matcher.message = "#{matcher.message}\n\n#{objectDiff v, value[k]}"
            return false
        return true
    when 'string'
      unless noMessage
        matcher.message = "#{matcher.message}\n\n#{stringDiff v, value[i]}"
      actual is value
    else
      actual is value

exports.equal = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be equal to #{util.inspect value}"
    @message = "Expected #{util.inspect actual}#{notText} to be equal to #{util.inspect value}"

    compare actual, value, this
