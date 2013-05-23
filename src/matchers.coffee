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

TAGS = if isCommonJS
  delStart: '\x1B[31m'
  delEnd: '\x1B[39m'
  insStart: '\x1B[32m'
  insEnd: '\x1B[39m'
  space: ''
else
  delStart: '<del>'
  delEnd: '</del>'
  insStart: '<ins>'
  insEnd: '</ins>'
  space: '\n'

escape = (s) ->
  n = s
  n = n.replace(/&/g, "&amp;")
  n = n.replace(/</g, "&lt;")
  n = n.replace(/>/g, "&gt;")
  n = n.replace(/"/g, "&quot;")
  n

diff = (o, n) ->
  ns = new Object()
  os = new Object()
  i = 0

  while i < n.length
    unless ns[n[i]]?
      ns[n[i]] =
        rows: new Array()
        o: null
    ns[n[i]].rows.push i
    i++
  i = 0

  while i < o.length
    unless os[o[i]]?
      os[o[i]] =
        rows: new Array()
        n: null
    os[o[i]].rows.push i
    i++
  for i of ns
    if ns[i].rows.length is 1 and typeof (os[i]) isnt "undefined" and os[i].rows.length is 1
      n[ns[i].rows[0]] =
        text: n[ns[i].rows[0]]
        row: os[i].rows[0]

      o[os[i].rows[0]] =
        text: o[os[i].rows[0]]
        row: ns[i].rows[0]
  i = 0

  while i < n.length - 1
    if n[i].text? and not n[i + 1].text? and n[i].row + 1 < o.length and not o[n[i].row + 1].text? and n[i + 1] is o[n[i].row + 1]
      n[i + 1] =
        text: n[i + 1]
        row: n[i].row + 1

      o[n[i].row + 1] =
        text: o[n[i].row + 1]
        row: i + 1
    i++
  i = n.length - 1

  while i > 0
    if n[i].text? and not n[i - 1].text? and n[i].row > 0 and not o[n[i].row - 1].text? and n[i - 1] is o[n[i].row - 1]
      n[i - 1] =
        text: n[i - 1]
        row: n[i].row - 1

      o[n[i].row - 1] =
        text: o[n[i].row - 1]
        row: i - 1
    i--
  o: o
  n: n

stringDiff = (o, n) ->
  o = o.replace(/\s+$/, "")
  n = n.replace(/\s+$/, "")
  out = diff((if o is "" then [] else o.split(/\s+/)), (if n is "" then [] else n.split(/\s+/)))
  str = ""
  oSpace = o.match(/\s+/g)
  unless oSpace?
    oSpace = [TAGS.space]
  else
    oSpace.push TAGS.space
  nSpace = n.match(/\s+/g)
  unless nSpace?
    nSpace = [TAGS.space]
  else
    nSpace.push TAGS.space
  if out.n.length is 0
    i = 0

    while i < out.o.length
      str += TAGS.delStart + escape(out.o[i]) + oSpace[i] + TAGS.delEnd
      i++
  else
    unless out.n[0].text?
      n = 0
      while n < out.o.length and not out.o[n].text?
        str += TAGS.delStart + escape(out.o[n]) + oSpace[n] + TAGS.delEnd
        n++
    i = 0

    while i < out.n.length
      unless out.n[i].text?
        str += TAGS.insStart + escape(out.n[i]) + nSpace[i] + TAGS.insEnd
      else
        pre = ""
        n = out.n[i].row + 1
        while n < out.o.length and not out.o[n].text?
          pre += TAGS.delStart + escape(out.o[n]) + oSpace[n] + TAGS.delEnd
          n++
        str += " " + out.n[i].text + nSpace[i] + pre
      i++
  str

keys = (o) -> k for k of o

isArray = (o) -> Object::toString.call(o) is '[object Array]'

squeeze = (s) -> s.replace /\s+/g, ' '

fill = (l=4, s=' ') ->
  o = ''
  o = "#{o}#{s}" while o.length < l
  o

indent = (string, ind=4) ->
  s = fill ind
  "#{string.replace /\n/g, "\n#{s}"}"

uniq = (arr) ->
  newArr = []
  newArr.push v for v in arr when v not in newArr
  newArr

inspect = (obj, depth=1) ->
  switch typeof obj
    when 'string' then "'#{obj}'"
    when 'number', 'boolean' then "#{obj}"
    when 'object'
      ind = fill depth * 2
      if isArray obj

        return '[]' if obj.length is 0
        "[#{
            obj.map((o) -> ind + inspect o, depth+1).join ', '
        }\n#{ind.substr 0, depth-2}]"
      else
        return '{}' if keys(obj).length is 0
        "{\n#{
          ("#{ind}#{k}: #{inspect v, depth + 1}" for k,v of obj).join ',\n'
        }\n#{ind[0..-3]}}"
    else
      ''

objectDiff = (left, right, depth=1) ->
  typeLeft = typeof left
  typeRight = typeof right

  unless typeLeft is typeRight
    return TAGS.delStart + inspect(left, depth) + TAGS.delEnd +
           TAGS.insStart + inspect(right, depth) + TAGS.insEnd

  switch typeLeft
    when 'string' then inspect stringDiff left, right
    when 'number', 'boolean' then stringDiff left.toString(), right.toString()
    when 'object'
      unless isArray(left) is isArray(right)
        return TAGS.delStart + inspect(left, depth) + TAGS.delEnd +
               TAGS.insStart + inspect(right, depth) + TAGS.insEnd

      ind = fill (depth) * 2
      prevInd = fill (depth - 1) * 2

      if isArray left
        l = Math.max left.length, right.length
        s = '['
        a = for i in [0..l-1]
          '\n' + ind + objectDiff(left[i], right[i], depth + 1)
        s += a.join(',') + "\n#{prevInd}]"

      else
        allKeys = uniq keys(left).concat keys(right)
        s = "{"
        a = for k in allKeys
          key = k + ': '
          key = TAGS.delStart + key + TAGS.delEnd unless right[k]
          key = TAGS.insStart + key + TAGS.insEnd unless left[k]

          '\n' + ind + key + objectDiff(left[k], right[k], depth + 1)
        s += a.join(',') + "\n#{prevInd}}"



compare = (actual, value, matcher, noMessage=false) ->
  switch typeof actual
    when 'object'
      if isArray actual
        unless noMessage
          matcher.message = "#{matcher.message}\n\n#{objectDiff actual, value}"
        return false if actual.length isnt value.length

        for v,i in value
          unless compare actual[i], v, matcher, true
            return false
        return true
      else
        unless noMessage
          matcher.message = "#{matcher.message}\n\n#{objectDiff actual, value}"
        return false if keys(actual).length isnt keys(value).length

        for k,v of value
          unless compare actual[k], v, matcher, true
            return false
        return true
    when 'string'
      unless noMessage
        matcher.message = "#{matcher.message}\n\n'#{stringDiff actual, value}'"
      actual is value
    else
      actual is value

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
          @message = "Expected #{actual}.#{state}#{notText} to be true but was #{actual[value]}"
          result = if typeof actual[state] is 'function'
            actual[state]()
          else
            actual[state]

        else
          @message = "Expected #{actual} to be #{value} but the state can't be found"
          result = false

        result
      when 'number', 'boolean', 'string'
        @message = "Expected #{actual}#{notText} to be #{value}"
        actual.valueOf() is value
      else
        @description = "should#{notText} be #{squeeze inspect value}"
        @message = "Expected #{inspect actual}#{notText} to be #{inspect value}"
        actual is value

exports.equal = (value) ->
  assert: (actual, notText) ->
    @description = "should#{notText} be equal to #{squeeze inspect value}"
    @message = "Expected #{inspect actual}#{notText} to be equal to #{inspect value}"
    compare actual, value, this

exports.match = (re) ->
  assert: (actual, notText) ->
    @description = "should#{notText} match #{re}"
    @message = "Expected '#{actual}'#{notText} to match #{re}"

    re.test actual

exports.throwAnError = (message) ->
  assert: (actual, notText) ->
    msg = if message? then " with message #{message}" else ''
    msg += " with arguments #{@arguments}" if @arguments?

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
        @description = "should have been called with #{@arguments}"
        @message = "Expected #{actual.spied}#{notText} to have been called with #{@arguments} but was called with #{actual.argsForCall}"

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

