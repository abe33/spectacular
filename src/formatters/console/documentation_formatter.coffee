
class spectacular.formatters.console.DocumentationFormatter
  constructor: (@example, @options) ->

  format: ->
    state = @example.result.state

    @options.lastDepth ||= 0
    @options.lastAncestorsStack ||= []

    ancestors = @example.ancestors.filter (e) -> e.ownDescription isnt ''
    dif = @cropAncestors ancestors, @options.lastAncestorsStack
    start = ancestors.length - dif.length
    res = @formatDocumentation @example, dif, start, COLOR_MAP[state]

    @options.lastAncestorsStack = ancestors
    res

  formatDocumentation: (example, stack, start, color) ->
    reverseStack = []
    reverseStack.unshift e for e in stack
    res = ''

    for e,i in reverseStack
      res += '\n' if i is 0
      res += '\n'
      res += utils.indent(utils.strip(e.ownDescription), (start + 1) * 2)
      start += 1

    res += '\n'
    res += utils.indent(
      spectacular.utils.colorize(utils.strip(example.ownDescriptionWithExpectations), color, @options.colors),
      (start + 1) * 2
    )

    @options.lastDepth = start

    res

  cropAncestors: (ancestors, lastAncestorsStack) ->
    a = []
    a.push elder for elder in ancestors when elder not in lastAncestorsStack
    a

