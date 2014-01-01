class spectacular.widgets.ExamplesList
  init: (@runner, @reporter) ->
    @examples = []
    @container = buildHTML spectacular.templates.list(chars: CHAR_MAP)
    @list = @container.querySelector('div')
    @totalValue = @container.querySelector('.all .total')
    @allValue = @container.querySelector('.all .value')
    @viewer = @reporter.widgets.filter((w)-> w.constructor is spectacular.widgets.ExampleViewer)[0]

    btn = @container.querySelector '.btn-collapse'
    btn.onclick = =>
      toggleClass @container, 'collapse'
      if hasClass @container, 'collapse'
        Array::forEach.call @list.children, (el) -> addClass el, 'collapse'
      else
        Array::forEach.call @list.children, (el) -> removeClass el, 'collapse'

    body = document.body
    openLeft = @container.querySelector '.btn-open-left'
    openLeft.onclick = =>
      if hasClass body, 'snapjs-left'
        @reporter.snapper.close()
      else
        @reporter.snapper.open('left')

    openRight = @container.querySelector '.btn-open-right'
    openRight.onclick = =>
      if hasClass body, 'snapjs-right'
        @reporter.snapper.close()
      else
        @reporter.snapper.open('right')

    @reporter.container.appendChild @container

  onStart: ->
    @totalValue.textContent = @runner.examples.length

  onResult: (event) ->
    example = event.target
    state = example.result.state
    if state in ['failure', 'errored'] and not hasClass @reporter.container, 'hide-success'
      addClass @container, 'fail'
      @viewer?.displayCard example
      @reporter.errorOccured()

    @buildExample example
    @examples.push example
    @allValue.textContent = @examples.length

  onEnd: (event) ->
    if hasClass @container, 'fail'
      addClass @container, 'failure'
    else
      addClass @container, 'success'

  buildExample: (example) ->
    node = @getParent example

    if example.failed
      selfAndAncestors node, (node) ->
        if hasClass node, 'success'
          removeClass node, 'success'
          addClass node, 'failure'

    node.appendChild @getExample example

  getExample: (example) ->
    state = example.result.state
    node = tag 'article', example.ownDescriptionWithExpectations, class: "example #{state}", id: @examples.length, title: example.fullDescription, 'data-index': stripHTML example.fullDescription.toLowerCase()

    node.onclick = =>
      @viewer.displayCard @examples[node.attributes.id.value]
      @reporter.openDetails()

    node

  getParent: (example) ->
    elders = example.ancestors
    elders.pop()

    reversed = []
    reversed.unshift a for a in elders

    node = @list
    n = 0
    for ancestor in reversed

      id = ancestor.ownDescription.replace(/^[\s\W]+|[\s\W]+$/g, '').replace(/[^\w\d]+/g, '-').toLowerCase()
      continue if id is ''

      parent = node
      node = node.querySelector "##{id}"
      unless node?
        node = @buildParent ancestor, id, n
        parent.appendChild node

      n++

    node

  buildParent: (ancestor, id, n) ->
    content = """
      <header title='#{ancestor.description}'>
      #{ancestor.ownDescription}
      </header>
    """
    index = ancestor.allExamples.map((ex) -> stripHTML ex.description.toLowerCase()).join()
    node = tag 'section', content, {id, class: "example-group #{if ancestor.failed then 'failure' else 'success'} level#{n}", 'data-index': index}

    header = node.querySelector 'header'
    header.onclick = -> toggleClass node, 'collapse'

    node
