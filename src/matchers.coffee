isCommonJS = typeof window is "undefined"

if isCommonJS
  difflet = require('difflet')(indent: 2)
  diff = require 'node-diff'
  util = require 'util'
  inspect = util.inspect
else
  exports = window

exports.exist =
  assert: (actual, notText) ->
    @description = "should#{notText} exist"
    @message = "Expected #{actual}#{notText} to exist"

    actual?

findStateMethodOrProperty = (obj, state) ->
  camelizedVersion = "is#{state.capitalize()}"
  snakedVersion = "is_#{state}"

  if obj[state]?
    state
  else if obj[camelizedVersion]?
    camelizedVersion
  else if obj[snakedVersion]?
    snakedVersion
  else
    null

squeeze = (s) ->
  s.replace /\s+/g, ' '

exports.be = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be #{value}"
    try
      switch typeof value
        when 'string'
          state = findStateMethodOrProperty actual, value

          if state?
            @message = squeeze(
              "Expected #{actual}.#{state}#{notText}
               to be true but was #{actual[value]}"
            )
            result = if typeof actual[state] is 'function'
              actual[state]()
            else
              actual[state]

          else
            @message = squeeze(
              "Expected #{actual} to be #{value} but
               the state can't be found"
            )
            result = false

          result
        when 'number', 'boolean', 'string'
          @message = squeeze "Expected #{actual}#{notText} to be #{value}"
          actual.valueOf() is value
        else
          @message = squeeze(
            "Expected #{inspect actual}#{notText} to be #{inspect value}"
          )
          actual is value

    catch e
      console.log e

objectDiff = (left, right) ->
  if isCommonJS
    difflet.compare left, right
  else
    ''

stringDiff = (left, right) ->
  res = diff(left, right)
  if isCommonJS
    res = res.replace('<del>', '\x1B[31m')
             .replace('</del>', '\x1B[39m')
             .replace('<ins>', '\x1B[32m')
             .replace('</ins>', '\x1B[39m')
  res

compare = (actual, value, matcher, noMessage=false) ->
  switch typeof actual
    when 'object'
      if Object::toString.call(actual) is '[object Array]'
        for v,i in actual
          unless compare v, value[i], matcher, true
            unless noMessage
              matcher.message = "#{matcher.message}\n\n#{objectDiff actual, value}"
            return false
        return true
      else
        for k,v of actual
          unless compare v, value[k], matcher, true
            unless noMessage
              matcher.message = "#{matcher.message}\n\n#{objectDiff actual, value}"
            return false
        return true
    when 'string'
      unless noMessage
        matcher.message = "#{matcher.message}\n\n#{stringDiff actual, value}"
      actual is value
    else
      actual is value

exports.equal = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be equal to #{inspect value}"
    @message = "Expected #{inspect actual}#{notText} to be equal to #{inspect value}"

    compare actual, value, this

exports.match = (re) ->
  assert: (actual, notText) ->
    @description = "should#{notText} match #{re}"
    @message = "Expected '#{actual}'#{notText} to match #{re}"

    re.test actual
