class spectacular.widgets.ExamplesList
  init: (@runner, @reporter) ->
    @examples = []
    @container = buildHTML spectacular.templates.list(chars: CHAR_MAP)
    @list = @container.querySelector('div')
    @viewer = @reporter.widgets.filter((w)-> w.constructor is spectacular.widgets.ExampleViewer)[0]

    btn = @container.querySelector '.btn-collapse'
    btn.onclick = =>
      toggleClass @container, 'collapse'
      if hasClass @container, 'collapse'
        Array::forEach.call @list.children, (el) -> addClass el, 'collapse'
      else
        Array::forEach.call @list.children, (el) -> removeClass el, 'collapse'

    html = document.querySelector 'html'
    openLeft = @container.querySelector '.btn-open-left'
    openLeft.onclick = =>
      if hasClass html, 'snapjs-left'
        window.snapper.close()
      else
        window.snapper.open('left')

    openRight = @container.querySelector '.btn-open-right'
    openRight.onclick = =>
      if hasClass html, 'snapjs-right'
        window.snapper.close()
      else
        window.snapper.open('right')


    document.body.appendChild @container

  onStart: ->


  onResult: (event) ->
    example = event.target
    state = example.result.state
    if state in ['failure', 'errored'] and not hasClass document.body, 'hide-success'
      addClass document.body, 'hide-success'
      @viewer.displayCard example

    @buildExample example

  onEnd: (event) ->

  buildExample: (example) ->
    node = @getParent example

    if example.failed
      selfAndAncestors node, (node) ->
        if hasClass node, 'success'
          removeClass node, 'success'
          addClass node, 'failure'

    node.appendChild @getExample example
    @examples.push example

  getExample: (example) ->
    state = example.result.state
    node = tag 'article', example.ownDescriptionWithExpectations, class: "example #{state}", id: @examples.length, title: example.fullDescription

    node.onclick = =>
      @viewer.displayCard @examples[node.attributes.id.value]
      snapper.open 'right'

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
    node = tag 'section', content, {id, class: "example-group #{if ancestor.failed then 'failure' else 'success'} level#{n}"}

    header = node.querySelector 'header'
    header.onclick = -> toggleClass node, 'collapse'

    node
