spectacular.formatters.browser = {}

utils = spectacular.utils

ancestors = (node, block) ->
  parent = node.parentNode

  if hasClass parent, 'example-group'
    block.call this, parent
    ancestors parent, block

wrapNode = (node) ->
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
