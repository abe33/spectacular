
$ ->
  hs = $('h2, h3, h4, h5, h6')

  afterInstall = false
  hs = hs.filter ->
    afterInstall = true if this.textContent is 'Install'
    return afterInstall and $(this).parents('.caniuse_static').length is 0

  toc = $ '<nav id="toc"><h2>Table Of Content</h2><ul></ul></nav>'
  tocList = toc.find('ul')
  hs.each ->
    level = parseInt(this.nodeName[1..])
    content = this.textContent
    id = content.replace /[^\w]+/g, '-'
    this.id = id
    tocList.append "<li class='level#{level}'><a href='##{id}'>#{content}</a></li>"

  $('hr').before toc

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

  $('tr').each ->
    tr = $(this)
    table = tr.parents('table')
    tr.addClass 'no-padding'
    tds = tr.find('td')
    tds.each ->
      td = $(this)
      newContent = $("<div>#{td.html()}</div>")
      td.html ''
      td.append newContent
      if tr.height() - 27 > 10
        newContent.addClass 'ellipsis'
        table.addClass('ellipsis') unless table.hasClass('ellipsis')
      newContent.attr 'data-min-height', 27
      newContent.attr 'data-max-height', tr.height()
      newContent.height 27

    tr.click ->
      tr.find('td div.ellipsis').each ->
        d = $(this)
        if d.height() is d.data('min-height')
          expandCell d.parents('td')
        else
          collapseCell d.parents('td')

  $('table').each ->
    return if $(this).find('.ellipsis').length is 0
    table = $(this).wrap('<div class="table-wrapper"/>').parent()
    controls = $('<div class="table-controls"></div>')
    table.append controls
    expandAll = $('<button class="expand" title="expand/collapse"><i class="icon-collapse"></i><i class="icon-collapse-top"></i></button>')
    expandAll.click ->
      expandAll.toggleClass('expanded')
      expanded = expandAll.hasClass('expanded')
      table.find('.ellipsis').each ->
        td = $(this).parents('td')
        toggleCellExpansion(td, expanded)



    controls.append expandAll
    new spectacular.SlidingObject controls[0], table[0]


