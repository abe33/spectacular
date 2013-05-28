
class Dummy
  constructor: (@args...) ->
    @property = 'value'

factory 'object', class: Object, ->
  set 'property', -> 16

  trait 'trait', ->
    set 'property', -> 20
    set 'name', 'irrelevant'

factory 'dummy', class: Dummy, ->
  createWith 'foo', 'bar'

  trait 'with createWith', ->
    createWith 'bar', 'foo'

describe create, ->
  context 'called with nothing', ->
    it -> should throwAnError /no factory name provided/

  context 'called with inexistant factory', ->
    it -> should throwAnError(/missing factory foo/).with 'foo'

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

  context 'called with a trait that defines constructor arguments', ->
    withArguments 'dummy', 'with createWith'

    itsReturn -> should equal property: 'value', args: ['bar', 'foo']

