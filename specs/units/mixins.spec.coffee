
sharedExample 'a collection like object', (options) ->
  {singular, plural} = options
  capitalizedSingular = spectacular.utils.capitalize singular

  context 'adding an item', ->
    given 'item', -> {}
    given 'item2', -> {}

    before -> @subject["add#{capitalizedSingular}"] @item

    specify 'the collection', ->
      @subject[plural].should contains @item

    specify "then calling has#{capitalizedSingular}", ->
      @subject["has#{capitalizedSingular}"](@item).should be true

    specify 'the item index', ->
      @subject["find#{capitalizedSingular}"](@item).should equal 0

    specify 'the item at index 0', ->
      @subject["#{singular}At"](0).should be @item

    context 'then removing it', ->
      before -> @subject["remove#{capitalizedSingular}"] @item

      specify 'the collection', ->
        @subject[plural].shouldnt contains @item

    context 'removing an inexistant item', ->
      before -> @subject["remove#{capitalizedSingular}"] @item2

      specify 'the collection', ->
        @subject[plural].should contains @item


class ClassWithCollection
  @include spectacular.HasCollection 'children', 'child'

  constructor: ->
    @children = []

describe ClassWithCollection, ->
  subject -> new ClassWithCollection

  itBehaveLike 'a collection like object', {
    singular: 'child'
    plural: 'children'
  }
