$ ->
  $('.lang-coffeescript').each ->
    pre = $(this).parent()
    coffee = pre.text()
    js = CoffeeScript.compile(coffee, bare: true)
    .replace(/return\s(\w+\()/g, '$1')

    code = hljs.highlight 'javascript', js

    pre.addClass 'lang-coffeescript'
    pre.wrap '<div class="coffee"></div>'
    div = pre.parent()
    div.prepend "<span class='toggle'>js</span>"
    div.append "<pre class='lang-javascript'><code>#{code.value}</code></pre>"

    toggle = div.find('.toggle')
    toggle.click ->
      div.toggleClass('compiled')
      if div.hasClass 'compiled'
        toggle.text 'coffee'
      else
        toggle.text 'js'
