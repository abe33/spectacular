spectacular.dom ||= {}

class spectacular.dom.NodeExpression
  @include spectacular.HasAncestors
  @include spectacular.HasCollection('expressions', 'expression')

  constructor: (@expression) ->
    @expressions = []

  isTextExpression: -> /^(\/|'|").*(\/|'|")$/gm.test @expression

  match: (el) ->
    el.is(@expression) and @expressions.every (e) -> e.contained el

  contained: (el) ->
    if @isTextExpression()
      @handleTextExpression el
    else
      found = el.find(@expression)
      found.length > 0 and @expressions.every (e) -> e.contained found

  handleTextExpression: (el) ->
    content = @expression[1..-2]
    if @expression.indexOf('/') is 0
      new RegExp(content).test el.text()
    else
      el.text() is content

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
        currentIndent = indent
        exprInst.parent = currentParent
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
