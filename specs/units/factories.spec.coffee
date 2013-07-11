
class Dummy
  constructor: (@args...) ->
    @property = 'value'

class DummyWithCustomBuild
  @new: ->
    instance = new DummyWithCustomBuild
    instance.property = 'value'
    instance

factoryMixin 'has parent', (factory) ->
  trait 'with parent', ->
    set 'parent', -> create factory.name

factoryMixin 'has field', (factory) ->
  set 'field', 'value'

factory 'object', class: Object, ->

  set 'property', -> 16

  trait 'trait', ->
    set 'property', -> 20
    set 'name', 'irrelevant'

factory 'dummy', class: Dummy, ->
  include 'has parent'

  createWith 'foo', 'bar'

  trait 'with createWith', ->
    createWith 'bar', 'foo'

  trait 'with createWith function', ->
    createWith -> ['bar', 'foo']

factory 'dummy', ->
  trait 'reopened factory', ->
    set 'reopened', true

factory 'dummy2', extends: 'dummy', ->
  createWith 'oof', 'rab'
  set 'baz', -> 42

factory 'dummy3', class: Dummy, ->
  include 'has field'

factory 'dummy_with_custom_build', class: DummyWithCustomBuild, ->
  build (cls, args) -> cls.new.apply(cls, args)

  trait 'trait', ->
    build (cls, args) ->
      instance = new cls
      instance.foo = 'bar'
      instance


describe create, ->
  context 'called with nothing', ->
    it -> should throwAnError /no factory name provided/

  context 'called with inexistant factory', ->
    it -> should throwAnError(/missing factory foo/).with 'foo'

  context 'called with inexistant trait', ->
    it -> should throwAnError(/unknown trait foo/).with 'dummy', 'foo'

  context 'called with only a factory', ->
    withArguments 'object'

    itsReturn -> should equal property: 16

  context 'called with a factory and a trait', ->
    withArguments 'object', 'trait'

    itsReturn -> should equal property: 20, name: 'irrelevant'

  context 'called with a factory and an option object', ->
    withArguments 'object', name: 'irrelevant'

    itsReturn -> should equal property: 16, name: 'irrelevant'

  context 'called with a factory that defines constructor arguments', ->
    withArguments 'dummy'

    itsReturn -> should equal property: 'value', args: ['foo', 'bar']

  context 'called with a trait', ->
    context 'that defines constructor arguments', ->
      withArguments 'dummy', 'with createWith'

      itsReturn -> should equal property: 'value', args: ['bar', 'foo']

    context 'that defines constructor arguments with a function', ->
      withArguments 'dummy', 'with createWith function'

      itsReturn -> should equal property: 'value', args: ['bar', 'foo']

  context 'called with a trait defined in a reopened factory', ->
    withArguments 'dummy', 'reopened factory'

    itsReturn -> should equal property: 'value', args: ['foo', 'bar'], reopened: true

  context 'called on a factory that defines a custom build', ->
    withArguments 'dummy_with_custom_build'

    itsReturn -> should equal property: 'value'

    context 'with a trait that override the custom build', ->
      withArguments 'dummy_with_custom_build', 'trait'

      itsReturn -> should equal foo: 'bar'

  context 'on a factory decorated with a mixin', ->
    withArguments 'dummy3'

    itsReturn -> should equal field: 'value', property: 'value', args: []

    context 'called with an included trait', ->
      subject -> create 'dummy', 'with parent'

      its 'parent', -> should exist




describe factory, ->
  context 'when using the extends option', ->
    context 'the created object', ->
      subject -> create 'dummy2'

      it -> should exist

      it 'inherit from the parent factory', ->
        should equal property: 'value', args: ['oof', 'rab'], baz: 42

runningSpecs('a factory without a class')
.shouldStopWith /no class provided/, ->
  factory 'foo', ->

runningSpecs('a factory extending an unexistant factory')
.shouldStopWith /parent factory 'bar' can't be found/, ->
  factory 'foo', extends: 'bar', ->

runningSpecs('a factory including an unexistant mixin')
.shouldStopWith /mixin 'bar' can't be found/, ->
  factory 'foo', class: Object, ->
    include 'bar'
