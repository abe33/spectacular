describe 'be', ->
  context 'when called with a string', ->
    subject ->
      truthy: true
      falsy: false
      isPending: -> true
      is_fulfilled: -> true

    it -> should be 'truthy'
    it -> shouldnt be 'falsy'
    it -> shouldnt be 'inexistant'
    it -> should be 'pending'
    it -> should be 'fulfilled'

  context 'when called with an object', ->
    subject -> {}

    it -> should be @subject
    it -> shouldnt be {}

describe 'equal', ->

  context 'with strings', ->
    subject -> 'irrelevant'

    it -> should equal 'irrelevant'
    it -> shouldnt equal 'tnavelerri'

  context 'with numbers', ->
    subject -> 10

    it -> should equal 10
    it -> shouldnt equal 1
    it -> shouldnt equal '10'

  context 'with objects', ->
    subject ->
      foo: 'bar'
      baz: {foo: 10}

    it -> should equal foo: 'bar', baz: {foo: 10}
    it -> shouldnt equal foo: 'baz', baz: {foo: 6}

describe 'exist', ->
  context 'with something', ->
    subject -> {}

    it -> should exist

  context 'with nothing', ->
    subject -> undefined

    it -> shouldnt exist

  context 'with a falsy value', ->
    subject -> false

    it -> should exist
