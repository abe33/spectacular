spectacular.dom ||= {}

class spectacular.dom.NodeExpression
  @include spectacular.HasAncestors
  @include spectacular.HasCollection('expressions', 'expression')

  constructor: (@expression) ->
    @matchesSelector =  document.matchesSelector or
                        document.mozMatchesSelector or
                        document.msMatchesSelector or
                        document.oMatchesSelector or
                        document.webkitMatchesSelector or
                        (selector) ->
                          node = this
                          nodes = (node.parentNode or document).querySelectorAll(selector)
                          i = -1

                          while nodes[++i] && nodes[i] isnt node
                            i

                          !!nodes[i]
    @expressions = []

  isTextExpression: -> /^(\/|'|").*(\/|'|")$/gm.test @expression

  match: (el) ->
    matchesSelector = if el.length?
      Array::every.call el, (e) => @matchesSelector.call(e, @expression)
    else
      @matchesSelector.call(el, @expression)

    matchesSelector and @expressions.every (e) -> e.contained el

  contained: (el) ->
    if @isTextExpression()
      @handleTextExpression el
    else
      if el?
        if el.length?
          found = []
          for e in el
            found.push n for n in e.querySelectorAll(@expression)
        else
          found = el.querySelectorAll(@expression)

        found.length > 0 and @expressions.every (e) -> e.contained found
      else
        false

  handleTextExpression: (el) ->
    textContent = if el.length?
      Array::map.call(el, (e) -> e.textContent).join ''
    else
      el.textContent

    content = @expression[1..-2]
    if @expression.indexOf('/') is 0
      new RegExp(content).test textContent
    else
      textContent is content

class spectacular.dom.DOMExpression
  @include spectacular.HasCollection('expressions', 'expression')

  constructor: (@source) ->
    @expressions = []
    @parse()

  parse: ->
    startingIndent = 0
    currentIndent = 0
    currentParent = this
    current = null

    @source.split('\n').forEach (line, i) =>
      invalidIndent = =>
        throw new Error "invalid indent on line #{i+1} of '#{@source}'"

      return if utils.strip(line).length is 0


      indent = @getIndent line
      expr = utils.strip line
      exprInst = new spectacular.dom.NodeExpression expr

      invalidIndent() if current is null and indent isnt 0

      if indent is currentIndent
        exprInst.parent = currentParent
        currentParent.addExpression exprInst
        current = exprInst

      else if indent is currentIndent + 1
        if current.isTextExpression()
          throw new Error "text expressions cannot have children on line #{i+1}"
        exprInst.parent = current
        current.addExpression exprInst
        currentIndent = indent
        currentParent = current
        current = exprInst

      else if indent < currentIndent and Math.round(indent) is indent
        dif = currentIndent - indent
        currentParent = current.nthAncestor Math.abs(dif)
        currentParent.addExpression exprInst
        exprInst.parent = currentParent
        currentIndent = indent
        current = exprInst

      else invalidIndent()

  getIndent: (line) ->
    re = /^(\s+).*/
    return 0 unless re.test line
    line = line.replace re, '$1'
    line.length / 2

  match: (el) -> @expressions.every (e) -> e.match el
  contained: (el) -> @expressions.every (e) -> e.contained el

  toString: -> @source
