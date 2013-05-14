
#### Mixins

class spectacular.HasAncestors
  ancestors: ->
    ancestors = []
    parent = @parent
    while parent
      ancestors.push parent
      parent = parent.parent
    ancestors

spectacular.HasCollection = (plural, singular) ->
  capitalizedSingular = singular.capitalize()
  capitalizedPlural = plural.capitalize()

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
  capitalizedProperty = property.capitalize()
  privateProperty = "own#{capitalizedProperty}"
  class ConcreteFollowUpProperty
    @included: (ctor) ->
      ctor.getter property, -> @[privateProperty] or @parent?[property]

spectacular.MergeUpProperty = (property) ->
  capitalizedProperty = property.capitalize()
  privateProperty = "own#{capitalizedProperty}"
  class ConcreteMergeUpProperty
    @included: (ctor) ->
      ctor.getter property, ->
        a = @[privateProperty]
        a = @parent[property].concat a if @parent?
        a

class spectacular.Describable
  @included: (ctor) ->
    ctor.getter 'description', ->
      if @parent?.description?
        space = ''
        space = ' ' unless @noSpaceBeforeDescription
        "#{@parent.description}#{space}#{@ownDescription}"
      else
        @ownDescription
