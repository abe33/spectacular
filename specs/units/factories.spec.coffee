
factory 'object', class: Object, ->
  set 'property', -> 16

  trait 'trait', ->
    set 'property', -> 20
    set 'name', 'irrelevant'

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
