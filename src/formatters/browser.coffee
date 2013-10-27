spectacular.formatters.browser = {}
spectacular.widgets = {}

{CHAR_MAP, COLOR_MAP, BADGE_MAP} = spectacular.formatters

utils = spectacular.utils

escapeHTML = (str) ->
  str
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')

selfAndAncestors = (node, block) ->
  block.call this, node
  ancestors node, block

ancestors = (node, block) ->
  parent = node.parentNode

  if hasClass parent, 'example-group'
    block.call this, parent
    ancestors parent, block

wrapNode = (node) ->
  return [] unless node?
  if node.length? then node else [node]

hasClass = (nl, cls) ->
  nl = wrapNode nl

  Array::every.call nl, (n) -> ///(\s|^)#{cls}(\s|$)///.test n.className

addClass = (nl, cls) ->
  nl = wrapNode nl
  Array::forEach.call nl, (node) ->
    node.className += " #{cls}" unless hasClass node, cls

removeClass = (nl, cls) ->
  nl = wrapNode nl
  Array::forEach.call nl, (node) ->
    node.className = node.className.replace cls, ''

toggleClass = (nl, cls) ->
  nl = wrapNode nl
  Array::forEach.call nl, (node) ->
    if hasClass node, cls
      removeClass node, cls
    else
      addClass node, cls

fixNodeHeight = (nl) ->
  nl = wrapNode nl
  Array::forEach.call nl, (node) ->
    node.style.height = "#{node.clientHeight}px"

tag = (tag, inner='', attrs={}, block) ->
  [inner, attrs, block] = ['', inner, attrs] if typeof inner is 'object'
  [inner, attrs, block] = ['', {}, inner] if typeof inner is 'function'

  inner = do block if typeof block is 'function'

  node = document.createElement tag
  node.setAttribute k, v for k,v of attrs

  if typeof inner is 'string'
    node.innerHTML = inner
  else
    node.appendChild inner

  node

buildHTML = (html) ->
  res = tag('div', html).children
  if res.length is 1
    res[0]
  else
    res

icon = (icon) -> tag 'i', class: "icon-#{icon}"

