describe 'be', ->
  subject ->
    truthy: true
    falsy: false

  it -> should be 'truthy'
  it -> shouldnt be 'falsy'
  it -> shouldnt be 'inexistant'

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
