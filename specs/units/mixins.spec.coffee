
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

  itBehavesLike 'a collection like object', {
    singular: 'child'
    plural: 'children'
  }

describe spectacular.EventDispatcher, ->
  given 'listener', ->
    dummy = {foo: ->}
    spyOn(dummy, 'foo')
    dummy.foo

  subject 'dispatcher', -> new spectacular.EventDispatcher

  context 'when adding a listener', ->
    before -> @dispatcher.on 'event', @listener

    specify 'calling hasListener("event")', ->
      @dispatcher.hasListener('event').should be true

    context 'and then removing it', ->
      before -> @dispatcher.off 'event', @listener

      specify 'calling hasListener("event")', ->
        @dispatcher.hasListener('event').should be false

    context 'and then dispatching a message', ->
      before -> @dispatcher.dispatch name: 'event', message: 'message'
      subject -> @listener

      specify 'the listener', -> should haveBeenCalled

class GlobalizableClass
  @include spectacular.Globalizable

  globalizable: ['test', 'testMethod', 'another_test_method']

  test: ->
  testMethod: ->
  another_test_method: ->

describe GlobalizableClass, ->
  subject -> new GlobalizableClass

  context ' when globalized', ->
    before -> @subject.globalize()
    after -> @subject.unglobalize()

    [
      'test',
      'testMethod',
      'test_method',
      'anotherTestMethod',
      'another_test_method'
    ].forEach (method) ->
      specify "the globalizable", ->
        expect(method, spectacular.global[method]).to exist
