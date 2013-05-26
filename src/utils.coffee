u = spectacular.utils ||= {}

spectacular.utils.squeeze = (s) -> s.replace /\s+/g, ' '

spectacular.utils.escape = (s) ->
  if isCommonJS
    s
  else
    n = s
    n = n.replace(/&/g, "&amp;")
    n = n.replace(/</g, "&lt;")
    n = n.replace(/>/g, "&gt;")
    n = n.replace(/"/g, "&quot;")
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
  return u.TAGS.delStart + o + u.TAGS.delEnd if not n? or n.length is 0
  return u.TAGS.insStart + n + u.TAGS.insEnd if not o? or o.length is 0
  o = o.replace(/\s+$/, "")
  n = n.replace(/\s+$/, "")
  out = u.diff((if o is "" then [] else o.split(/\s+/)), (if n is "" then [] else n.split(/\s+/)))
  str = ""
  oSpace = o.match(/\s+/g)
  unless oSpace?
    oSpace = [u.TAGS.space]
  else
    oSpace.push u.TAGS.space
  nSpace = n.match(/\s+/g)
  unless nSpace?
    nSpace = [u.TAGS.space]
  else
    nSpace.push u.TAGS.space
  if out.n.length is 0
    i = 0

    while i < out.o.length
      str += u.TAGS.delStart + u.escape(out.o[i]) + oSpace[i] + u.TAGS.delEnd
      i++
  else
    unless out.n[0].text?
      n = 0
      while n < out.o.length and not out.o[n].text?
        str += u.TAGS.delStart + u.escape(out.o[n]) + oSpace[n] + u.TAGS.delEnd
        n++
    i = 0

    while i < out.n.length
      unless out.n[i].text?
        str += u.TAGS.insStart + u.escape(out.n[i]) + nSpace[i] + u.TAGS.insEnd
      else
        pre = ""
        n = out.n[i].row + 1
        while n < out.o.length and not out.o[n].text?
          pre += u.TAGS.delStart + u.escape(out.o[n]) + oSpace[n] + u.TAGS.delEnd
          n++
        str += "" + out.n[i].text + nSpace[i] + pre
      i++
  str

spectacular.utils.keys = (o) -> k for k of o

spectacular.utils.isArray = (o) -> Object::toString.call(o) is '[object Array]'

spectacular.utils.squeeze = (s) -> s.replace /\s+/g, ' '

spectacular.utils.fill = (l=4, s=' ') ->
  o = ''
  o = "#{o}#{s}" while o.length < l
  o

spectacular.utils.indent = (string, ind=4) ->
  s = u.fill ind
  "#{string.replace /\n/g, "\n#{s}"}"

spectacular.utils.uniq = (arr) ->
  newArr = []
  newArr.push v for v in arr when v not in newArr
  newArr

spectacular.utils.inspect = (obj, depth=1) ->
  switch typeof obj
    when 'string' then "'#{obj}'"
    when 'number', 'boolean' then "#{obj}"
    when 'object'
      ind = u.fill depth * 2
      if u.isArray obj

        return '[]' if obj.length is 0
        "[\n#{
            obj.map((o) -> ind + u.inspect o, depth+1).join ',\n'
        }\n#{ind[0..-3]}]"
      else
        return '{}' if u.keys(obj).length is 0
        "{\n#{
          ("#{ind}#{k}: #{u.inspect v, depth + 1}" for k,v of obj).join ',\n'
        }\n#{ind[0..-3]}}"
    else
      ''

spectacular.utils.objectDiff = (left, right, depth=1) ->
  typeLeft = typeof left
  typeRight = typeof right

  unless typeLeft is typeRight
    s = ''
    s += u.TAGS.delStart + u.inspect(left, depth) + u.TAGS.delEnd if left?
    s += u.TAGS.insStart + u.inspect(right, depth) + u.TAGS.insEnd if right?
    return s

  switch typeLeft
    when 'string' then u.inspect u.stringDiff left, right
    when 'number', 'boolean' then u.stringDiff left.toString(), right.toString()
    when 'object'
      unless u.isArray(left) is u.isArray(right)
        return u.TAGS.delStart + u.inspect(left, depth) + u.TAGS.delEnd +
               u.TAGS.insStart + u.inspect(right, depth) + u.TAGS.insEnd

      ind = u.fill (depth) * 2
      prevInd = u.fill (depth - 1) * 2

      if u.isArray left
        l = Math.max left.length, right.length
        s = '['
        a = for i in [0..l-1]
          '\n' + ind + u.objectDiff(left[i], right[i], depth + 1)
        s += a.join(',') + "\n#{prevInd}]"

      else
        allKeys = u.uniq u.keys(left).concat u.keys(right)
        s = "{"
        a = for k in allKeys
          key = k + ': '
          p = ''
          unless right[k]
            p = u.TAGS.delStart + "#{key}#{left[k]}" + u.TAGS.delEnd
          else unless left[k]
            p = u.TAGS.insStart + "#{key}#{right[k]}" + u.TAGS.insEnd
          else
            p = key + u.objectDiff(left[k], right[k], depth + 1)

          '\n' + ind + p
        s += a.join(',') + "\n#{prevInd}}"



spectacular.utils.compare = (actual, value, matcher, noMessage=false) ->
  switch typeof actual
    when 'object'
      if u.isArray actual
        unless noMessage
          matcher.message = "#{matcher.message}\n\n#{u.objectDiff actual, value}"
        return false if actual.length isnt value.length

        for v,i in value
          unless u.compare actual[i], v, matcher, true
            return false
        return true
      else
        unless noMessage
          matcher.message = "#{matcher.message}\n\n#{u.objectDiff actual, value}"
        return false if u.keys(actual).length isnt u.keys(value).length

        for k,v of value
          unless u.compare actual[k], v, matcher, true
            return false
        return true
    when 'string'
      unless noMessage
        matcher.message = "#{matcher.message}\n\n'#{u.stringDiff actual, value}'"
      actual is value
    else
      actual is value

spectacular.utils.findStateMethodOrProperty = (obj, state) ->
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
