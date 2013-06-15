utils = spectacular.utils ||= {}

spectacular.utils.squeeze = (s) -> s.replace /\s+/g, ' '

spectacular.utils.strip = (s) -> s.replace /^\s+|\s+$/g, ''

spectacular.utils.capitalize = (s) -> s.replace /^(\w)/, (m, c) -> c.toUpperCase()

spectacular.utils.underscore = (s) ->
  s.replace(/([a-z])([A-Z])/g, "$1_$2")
  .split(/[-/]|\s/g)
  .join("_")
  .toLowerCase()

spectacular.utils.camelize = (s) ->
  a = s.toLowerCase().split /[_\s-]/
  s = a.shift()
  s = "#{s}#{utils.capitalize w}" for w in a
  s

spectacular.utils.snakify = (o) ->
  for k,v of o
    o[utils.underscore k] = v

spectacular.utils.keys = (o) -> k for k of o

spectacular.utils.isArray = (o) -> Object::toString.call(o) is '[object Array]'

spectacular.utils.literalEnumeration = (array) ->
  if array.length > 1
    last = array.pop()
    result = array.join(', ')
    result += " and #{last}"
  else
    result = array.toString()

  result

spectacular.utils.fill = (l=4, s=' ') ->
  o = ''
  o = "#{o}#{s}" while o.length < l
  o

spectacular.utils.uniq = (arr) ->
  newArr = []
  newArr.push v for v in arr when v not in newArr
  newArr

spectacular.utils.andOrBut = (bool) ->
  if bool then 'and' else 'but'

spectacular.utils.escapeDiff = (s) ->
  utils.escape(
    s
    .replace(/<del>/g, '[[del]]')
    .replace(/<\/del>/g, '[[/del]]')
    .replace(/<ins>/g, '[[ins]]')
    .replace(/<\/ins>/g, '[[/ins]]')
  )
  .replace(/\[\[del\]\]/g, '<del>')
  .replace(/\[\[\/del\]\]/g, '</del>')
  .replace(/\[\[ins\]\]/g, '<ins>')
  .replace(/\[\[\/ins\]\]/g, '</ins>')

spectacular.utils.escape = (s) ->
  n = s
  n = n.replace(/&/g, '&amp;')
  n = n.replace(/</g, '&lt;')
  n = n.replace(/>/g, '&gt;')
  n = n.replace(/"/g, '&quot;')
  n

spectacular.utils.unescape = (s) ->
  n = s
  n = n.replace(/&amp;/g, '&')
  n = n.replace(/&lt;/g, '<')
  n = n.replace(/&gt;/g, '>')
  n = n.replace(/&quot;/g, '"')
  n

spectacular.utils.indent = (string, ind=4) ->
  s = ''
  s = "#{s} " for i in [0..ind-1]

  "#{s}#{string.replace /\n/g, "\n#{s}"}"

spectacular.utils.padRight = (string, pad=4) ->
  string = string.toString()
  string = " #{string}" while string.length < pad
  string

spectacular.utils.toggle = (value, c1, c2) -> if value then c2 else c1

spectacular.utils.TAGS = if isCommonJS
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
  space: ''

spectacular.utils.ins = (str) ->
  utils.TAGS.insStart + str + utils.TAGS.insEnd

spectacular.utils.del = (str) ->
  utils.TAGS.delStart + str + utils.TAGS.delEnd

spectacular.utils.descOfNode = (actual) ->
  if actual?
    if actual.length?
      utils.inspect Array::map.call actual, (e) -> e.outerHTML
    else
      utils.inspect actual.outerHTML
  else
    actual


# Javascript Diff Algorithm
# By John Resig (http://ejohn.org/)
# Modified by Chu Alan "sprite"
#
# Released under the MIT license.
#
# More Info:
# http://ejohn.org/projects/javascript-diff-algorithm/
spectacular.utils.diff = (o, n) ->
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

spectacular.utils.stringDiff = (o, n) ->
  return utils.del o if not n? or n.length is 0
  return utils.ins n if not o? or o.length is 0
  o = String(o).replace(/\s+$/, "")
  n = String(n).replace(/\s+$/, "")
  out = utils.diff((if o is "" then [] else o.split(/\s+/)), (if n is "" then [] else n.split(/\s+/)))
  str = ""
  oSpace = o.match(/\s+/g)
  unless oSpace?
    oSpace = [utils.TAGS.space]
  else
    oSpace.push utils.TAGS.space
  nSpace = n.match(/\s+/g)
  unless nSpace?
    nSpace = [utils.TAGS.space]
  else
    nSpace.push utils.TAGS.space
  if out.n.length is 0
    i = 0

    while i < out.o.length
      str += utils.del utils.escape(out.o[i]) + oSpace[i]
      i++
  else
    unless out.n[0].text?
      n = 0
      while n < out.o.length and not out.o[n].text?
        str += utils.del utils.escape(out.o[n]) + oSpace[n]
        n++
    i = 0

    while i < out.n.length
      unless out.n[i].text?
        str += utils.ins utils.escape(out.n[i]) + nSpace[i]
      else
        pre = ""
        n = out.n[i].row + 1
        while n < out.o.length and not out.o[n].text?
          pre += utils.del utils.escape(out.o[n]) + oSpace[n]
          n++
        str += "" + out.n[i].text + nSpace[i] + pre
      i++
  str

spectacular.utils.inspect = (obj, depth=1, lookup=[]) ->

  switch typeof obj
    when 'string' then "'#{obj}'"
    when 'number', 'boolean' then "#{obj}"
    when 'object'
      return 'null' unless obj?
      return '[circular]' if obj in lookup
      lookup.push obj
      ind = utils.fill depth * 2
      if utils.isArray obj

        return '[]' if obj.length is 0
        "[\n#{
            obj.map((o) -> ind + utils.inspect o, depth+1, lookup).join ',\n'
        }\n#{ind[0..-3]}]"
      else
        return '{}' if utils.keys(obj).length is 0
        "{\n#{
          ("#{ind}#{k}: #{utils.inspect v, depth+1, lookup}" for k,v of obj).join ',\n'
        }\n#{ind[0..-3]}}"
    when 'function'
      if obj.name
        obj.name
      else if obj._name
        obj._name
      else
        obj.toString()
    else
      'undefined'

spectacular.utils.objectDiff = (left, right, depth=1) ->
  typeLeft = typeof left
  typeRight = typeof right

  unless typeLeft is typeRight
    s = ''
    s += utils.del utils.inspect(left, depth) if left?
    s += utils.ins utils.inspect(right, depth) if right?
    return s

  switch typeLeft
    when 'string' then utils.inspect utils.stringDiff left, right
    when 'number', 'boolean' then utils.stringDiff left.toString(), right.toString()
    when 'object'
      unless utils.isArray(left) is utils.isArray(right)
        return utils.del(utils.inspect left, depth) +
               utils.ins(utils.inspect right, depth)

      ind = utils.fill (depth) * 2
      prevInd = utils.fill (depth - 1) * 2

      if utils.isArray left
        l = Math.max left.length, right.length
        s = '['
        a = for i in [0..l-1]
          '\n' + ind + utils.objectDiff(left[i], right[i], depth + 1)
        s += a.join(',') + "\n#{prevInd}]"

      else
        allKeys = utils.uniq utils.keys(left).concat utils.keys(right)
        s = "{"
        a = for k in allKeys
          key = k + ': '
          p = ''
          unless right[k]
            p = utils.del "#{key}#{left[k]}"
          else unless left[k]
            p = utils.ins "#{key}#{right[k]}"
          else
            p = key + utils.objectDiff(left[k], right[k], depth + 1)

          '\n' + ind + p
        s += a.join(',') + "\n#{prevInd}}"

spectacular.utils.compare = (actual, value, matcher, noMessage=false) ->
  switch typeof value
    when 'object'
      if utils.isArray actual
        unless noMessage
          matcher.message = "#{matcher.message}\n\n#{utils.objectDiff actual, value}"
        return false if actual.length isnt value.length

        for v,i in value
          unless utils.compare actual[i], v, matcher, true
            return false
        return true
      else
        unless noMessage
          matcher.message = "#{matcher.message}\n\n#{utils.objectDiff actual, value}"
        return false if utils.keys(actual).length isnt utils.keys(value).length

        for k,v of value
          unless utils.compare actual[k], v, matcher, true
            return false
        return true
    when 'string'
      unless noMessage
        matcher.message = "#{matcher.message}\n\n'#{utils.stringDiff actual, value}'"
      actual is value
    else
      actual is value

spectacular.utils.findStateMethodOrProperty = (obj, state) ->
  camelizedVersion = "is#{utils.capitalize state}"
  snakedVersion = "is_#{state}"

  if obj[state]?
    state
  else if obj[camelizedVersion]?
    camelizedVersion
  else if obj[snakedVersion]?
    snakedVersion
  else
    null

v._name = k for k,v of utils
