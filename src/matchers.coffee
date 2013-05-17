isCommonJS = typeof window is "undefined"

if isCommonJS
  difflet = require('difflet')(indent: 2)
  diff = require 'node-diff'
  util = require 'util'
  utils = require './utils'
  inspect = util.inspect
  Q = require 'q'
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

exports.be = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be #{value}"
    switch typeof value
      when 'string'
        state = findStateMethodOrProperty actual, value

        if state?
          @message = utils.squeeze(
            "Expected #{actual}.#{state}#{notText}
             to be true but was #{actual[value]}"
          )
          result = if typeof actual[state] is 'function'
            actual[state]()
          else
            actual[state]

        else
          @message = utils.squeeze(
            "Expected #{actual} to be #{value} but
             the state can't be found"
          )
          result = false

        result
      when 'number', 'boolean', 'string'
        @message = utils.squeeze(
          "Expected #{actual}#{notText} to be #{value}"
        )
        actual.valueOf() is value
      else
        @message = utils.squeeze(
          "Expected #{inspect actual}#{notText} to be #{inspect value}"
        )
        actual is value

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

exports.haveBeenCalled =
  assert: (actual, notText) ->
    if typeof actual?.spied is 'function'
      if @arguments?
        @description = "should have been called with #{@arguments}"
        @message = utils.squeeze(
          "Expected #{actual.spied}#{notText} to have been called with
          #{@arguments} but was called with #{actual.argsForCall}"
        )

        actual.argsForCall.length > 0 and actual.argsForCall.some (a) =>
          equal(a).assert(@arguments, '')
      else
        @description = "should have been called"
        @message = "Expected #{actual.spied}#{notText} to have been called"
        actual.argsForCall.length > 0
    else
      @message = "Expected a spy but it was #{actual}"
      false

  with: (args...) ->
    @arguments = args
    this

