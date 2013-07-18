
$ ->
  class SlidingObject
    constructor: (@target, @container) ->
      previousOnScroll = window.onscroll
      doc = document.documentElement
      body = document.body

      window.onscroll = =>
        do previousOnScroll if previousOnScroll?

        topMin = @getOffset @container
        topMax = topMin + @container.clientHeight - @target.clientHeight
        top = (doc and doc.scrollTop or body and body.scrollTop or 0)
        top = Math.min(topMax, Math.max(topMin, top + 100)) - topMin
        @target.style.top = "#{top}px"

    getOffset: (node) ->
      return node.offsetTop if node.nodeName.toLowerCase() is 'body'
      node.offsetTop + @getOffset node.parentNode

  hs = $('h2, h3, h4, h5, h6')
  hs = hs.filter ->  $(this).parents('.caniuse_static, header').length is 0

  if hs.length > 0
    tocHeader = $ '<h2>Table Of Content</h2>'
    tocList = $ '<ul></ul>'
    hs.each ->
      level = parseInt(this.nodeName[1..])
      content = this.textContent
      id = content.replace /[^\w]+/g, '-'
      this.id = id
      tocList.append "<li class='level#{level}'><a href='##{id}'>#{content}</a></li>"

    $('#toc').append tocHeader
    $('#toc').append tocList

  $('pre.coffeescript code').each ->
    pre = $(this).parent()
    coffee = pre.text()
    code = hljs.highlight('ruby', coffee).value
    pre.removeClass 'coffeescript'
    $(this).addClass 'lang-coffeescript'
    $(this).html code

  $('.lang-coffeescript').each ->
    pre = $(this).parent()
    coffee = pre.text()
    js = CoffeeScript.compile(coffee, bare: true)
    .replace(/return\s(\w+\()/g, '$1')

    code = hljs.highlight('javascript', js).value.replace(/\n$/gm, '')

    pre.addClass 'lang-coffeescript'
    pre.wrap '<div class="code"></div>'
    div = pre.parent()
    div.height pre.height()
    div.prepend "<span class='toggle'>
      <span class='coffee' data-text='view as js'>view as js</span>
      <span class='js' data-text='view as coffee'>view as coffee</span>
    </span>"
    div.append "<pre class='lang-javascript'><code class='lang-javascript'>#{code}</code></pre>"

    toggle = div.find('.toggle')
    toggle.click ->
      div.toggleClass('compiled')
      if div.hasClass 'compiled'
        div.height div.find('.lang-javascript').data 'height'
      else
        div.height div.find('.lang-coffeescript').data 'height'

  pres = $('pre code')
  pres.each (i,el) ->

    el = $(el)
    parent = el.parent()
    parent.attr 'data-height', parent.height()
    text = el.html()
    lines = text.split('\n')
    parent.prepend "<ol>#{lines.map((l,i) -> "<li>#{i+1}</li>").join('')}</ol>"

  toggleCellExpansion = (td, bool) ->
    tr = td.parents('tr')
    ellipsis = td.find('.ellipsis')
    if bool
      ellipsis.height ellipsis.data('max-height')
      tr.addClass('open') unless tr.hasClass('open')
    else
      ellipsis.height ellipsis.data('min-height')
      tr.removeClass('open') if tr.hasClass('open')

  expandCell = (td) -> toggleCellExpansion(td, true)
  collapseCell = (td) -> toggleCellExpansion(td, false)

  $('.nav-menu-button').on 'click', (e) ->
    $('#nav').toggleClass('active')

    controls.append expandAll
    new SlidingObject controls[0], table[0]


