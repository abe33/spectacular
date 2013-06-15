
#### Mixins

class spectacular.HasAncestors
  @included: (ctor) ->
    ctor.getter 'ancestors', ->
      ancestors = []
      parent = @parent
      while parent
        ancestors.push parent
        parent = parent.parent
      ancestors

    ctor.ancestorsScope = (name, block) ->
      @getter name, -> @ancestors.filter block

  nthAncestor: (level) ->
    level = 1 if level < 1
    parent = this
    n = 0
    for n in [0..level]
      parent = parent.parent

    parent

class spectacular.Globalizable
  @excluded: ['globalize', 'unglobalize', 'keepContext', 'globalizeMember', 'unglobalizeMember', 'globalizable', 'globalized', 'alternate', 'previous']

  keepContext: true

  globalize: ->
    @previous ||= {}
    @globalizable.forEach (k) =>
      unless k in (@constructor.excluded or Globalizable.excluded)
        @globalizeMember k, @[k]

    @globalized = true

  unglobalize: ->
    @globalizable.forEach (k) =>
      unless k in (@constructor.excluded or Globalizable.excluded)
        @unglobalizeMember k, @[k]

    @globalized = false

  globalizeMember: (key, value, alternate=true) ->
    _global = spectacular.global
    @previous[key] = _global[key] if _global[key]?
    self = this
    if typeof value is 'function'
      value._name = key unless value._name?
      if @keepContext
        proxy = -> value.apply self, arguments
        proxy._name = key
        _global[key] = proxy
      else
        _global[key] = value
    else
      _global[key] = value

    if alternate
      alt = @alternate key
      @globalizeMember alt, value, false if alt isnt key

  unglobalizeMember: (key, value, alternate=true) ->
    _global = spectacular.global

    if @previous[key]?
      _global[key] = @previous[key]
    else
      delete _global[key]

    if alternate
      alt = @alternate key
      @unglobalizeMember alt, value, false if alt isnt key

  alternate: (key) ->
    if key.indexOf('_') is -1
      utils.underscore key
    else
      utils.camelize key

class spectacular.GlobalizableObject
  @include spectacular.Globalizable
  @excluded = spectacular.Globalizable.excluded.concat 'set'

  constructor: (@__globalizable...) ->

  Object.defineProperty this.prototype, 'globalizable',
    configurable: true
    get: ->
      if @__globalizable.length > 0
        @__globalizable
      else
        utils.keys this

  set: (property, value) ->
    @[property] = value
    @globalizeMember property, value if @globalized

spectacular.HasCollection = (plural, singular) ->
  capitalizedSingular = utils.capitalize singular
  capitalizedPlural = utils.capitalize plural

  mixin = class ConcreteHasCollection
    @included: (ctor) ->
      ctor["#{plural}Scope"] = (name, block) ->
        ctor.getter name, -> @[plural].filter block

  mixin::["add#{capitalizedSingular}"] = (items...) ->
    @[plural].push item for item in items when item not in @[plural]

  mixin::["remove#{capitalizedSingular}"] = (items...) ->
    newArray = []
    newArray.push item for item in @[plural] when item not in items
    @[plural] = newArray

  mixin::["#{singular}At"] = (index) ->
    @[plural][index]

  mixin::["find#{capitalizedSingular}"] =
  mixin::["indexOf#{capitalizedSingular}"] = (item) ->
    @[plural].indexOf item

  mixin::["has#{capitalizedSingular}"] =
  mixin::["contains#{capitalizedSingular}"] = (item) ->
    @[plural].indexOf(item) isnt -1

  mixin::["#{plural}Length"] =
  mixin::["#{plural}Size"] =
  mixin::["#{plural}Count"] = ->
    @[plural].length

  mixin

spectacular.HasNestedCollection = (name, options={}) ->
  through = options.through
  throw new Error('missing through option') unless through?

  mixin = class ConcreteHasNestedCollection
    @included: (ctor) ->
      ctor["#{name}Scope"] = (scopeName, block) ->
        ctor.getter scopeName, -> @[name].filter block
      ctor.getter name, ->
        items = []
        @[through].forEach (item) ->
          items.push(item)
          items = items.concat(item[name]) if item[name]?
        items

  mixin

spectacular.FollowUpProperty = (property) ->
  capitalizedProperty = utils.capitalize property
  privateProperty = "own#{capitalizedProperty}"
  class ConcreteFollowUpProperty
    @included: (ctor) ->
      ctor.accessor property, {
        get: -> @[privateProperty] or @parent?[property]
        set: (value) -> @[privateProperty] = value
      }

spectacular.MergeUpProperty = (property) ->
  capitalizedProperty = utils.capitalize property
  privateProperty = "own#{capitalizedProperty}"
  class ConcreteMergeUpProperty
    @included: (ctor) ->
      ctor.accessor property, {
        get: ->
          a = @[privateProperty]
          a = @parent[property].concat a if @parent?
          a
        set: (value) -> @[privateProperty] = value
      }

class spectacular.Describable
  @included: (ctor) ->
    ctor.getter 'description', ->
      if @parent?.description?
        space = ''
        space = ' ' unless @noSpaceBeforeDescription
        "#{@parent.description}#{space}#{@ownDescription}"
      else
        @ownDescription

class spectacular.Event
  constructor: (@name, @target) ->

class spectacular.EventDispatcher
  on: (event, callback) ->
    @listeners ||= {}
    @listeners[event] ||= []

    @listeners[event].push callback unless callback in @listeners[event]

  off: (event, callback) ->
    if @listeners?[event]? and callback in @listeners[event]
      @listeners[event].splice @listeners[event].indexOf(callback), 1

  hasListener: (event) ->
    @listeners?[event]? and @listeners[event].length > 0

  dispatch: (event) ->
    @listeners?[event.name]?.forEach (listener) -> listener event
