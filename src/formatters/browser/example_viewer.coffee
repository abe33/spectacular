
class spectacular.widgets.ExampleViewer
  init: (@runner) ->
    @container = buildHTML spectacular.templates.viewer()
    @view = @container.querySelector 'div'
    document.body.appendChild @container

  displayCard: (example) ->
    @view.innerHTML = @getCard example

    @stack = @view.querySelector '.stack'
    @expectationMessage = @view.querySelector '.expectation-message'
    @expectations = @view.querySelectorAll '.expectation'

    if @expectations.length > 0
      @each @expectations, (node, i) =>
        index = node.attributes['data-expectation'].value
        expectation = example.result.expectations[index]

        node.onclick = => @displayExpectationDetails node, expectation

        @displayExpectationDetails node, expectation if i is 0
    else
      if example.result.expectations.length is 0 and example.examplePromise.reason
        @displayStack example.examplePromise.reason.stack

  displayExpectationDetails: (node, expectation) ->
    @each @expectations, (el) -> removeClass el, 'active'

    @expectationMessage.textContent = expectation.message
    @expectationMessage.setAttribute 'class', if expectation.success then 'expectation-message success' else 'expectation-message failure'

    @clearStack()
    @displayStack(expectation.trace.stack) if expectation.trace?

    addClass node, 'active'

  clearStack: -> @stack.innerHTML = ''
  displayStack: (stack) ->

    parser = new spectacular.errors.ErrorParser(stack)

    parser.lines.forEach (stackLine, i) =>
      {file, line, column, method} = parser.details stackLine

      div = tag 'div', -> tag 'a', escapeHTML stackLine
      div.onclick = =>
        if hasClass div, 'has-source'
          @hideSource(div)
        else
          @displayLineSource div, file, line, column

      @stack.appendChild div

      @displayLineSource div, file, line, column if i is 0

  hideSource: (div) ->
    div.removeChild(div.children[1])
    removeClass div, 'has-source'

  displayLineSource: (div, file, line, column) ->
    f = new spectacular.formatters.console.ErrorSourceFormatter @runner.options, file, line, column
    w = (s,c) -> "<span class='#{c}'>#{s}</span>"

    f.format()
    .then (result) ->
      div.appendChild tag 'pre', ->
        lines = result.replace(/^\n|\n$/g, '').split('\n')
        lines = lines.map (line) ->
          line = line.replace(/^\s+(\d+\s)*\|/gm, w '$&', 'line-number')
          tag('span', line).outerHTML

        lines.join('\n')


      addClass div, 'has-source'


  each: (nodes, block) -> Array::forEach.call nodes, block

  getCard: (example) -> spectacular.templates.card({example})

  onStart:(event) ->
  onResult:(event) ->
  onEnd:(event) ->
