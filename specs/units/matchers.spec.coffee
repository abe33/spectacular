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

  context 'with an object', ->

    subject ->
      foo: 'bar'
      baz: {foo: 10}

    it -> should equal foo: 'bar', baz: {foo: 10}
    it -> shouldnt equal foo: 'baz', baz: {foo: 6}

    context 'that is empty', ->
      subject -> {}

      it -> shouldnt equal a: 10, b: 10, c: 10

    context 'that have an extra property', ->
      subject -> {a: 10, b: 10, c: 10, d: 10}

      it -> shouldnt equal a: 10, b: 10, c: 10

  context 'with an array', ->
    subject -> [0,1,2]

    it -> should equal [0,1,2]
    it -> shouldnt equal [2,1,0]

    context 'that is empty', ->
      subject -> []

      it -> shouldnt equal [10, 10, 10]

    context 'that have an extra value', ->
      subject -> [10, 10, 10, 10]

      it -> shouldnt equal [10, 10, 10]

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

describe 'match', ->
  subject -> 'irrelevant'

  it -> should match /irrelevant/
  it -> shouldnt match /tnavelerri/

describe 'haveBeenCalled', ->
  given 'object', -> method: -> 42

  the -> @object.method.shouldnt haveBeenCalled

  context 'on a spied method', ->
    before -> spyOn(@object, 'method')

    the -> @object.method.shouldnt haveBeenCalled

    context 'when called', ->
      before -> @object.method()

      the -> @object.method.should haveBeenCalled

    context 'when called with arguments', ->
      before -> @object.method 10, 'foo'

      the -> @object.method.shouldnt haveBeenCalled.with 'foo', 10
      the -> @object.method.should haveBeenCalled.with 10, 'foo'






