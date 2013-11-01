describe be, ->
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

  context 'when called with a function', ->
    subject -> {}

    it -> should be Object
    it -> shouldnt be String

    context 'and that the value is a function', ->
      subject -> Object

      it -> should be Object
      it -> shouldnt be String

describe equal, ->

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
    it -> shouldnt equal [10, 'foo']

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

describe beWithin, ->

  context 'with integers', ->
    subject -> 10

    context 'integer delta', ->
      it -> should beWithin(1).of(9)
      it -> shouldnt beWithin(1).of(13)

    context 'float delta', ->
      it -> should beWithin(1.1).of(9)
      it -> shouldnt beWithin(1.1).of(13)

  context 'with floats', ->
    subject -> 22.0 / 7

    context 'integer delta', ->
      it -> should beWithin(1).of(3.0)
      it -> shouldnt beWithin(1).of(13.0)

    context 'float delta', ->
      it -> should beWithin(0.01).of(3.14)
      it -> shouldnt beWithin(0.01).of(3.2)

  context 'with integer and float', ->
    subject -> 10

    context 'integer delta', ->
      it -> should beWithin(1).of(10.0)
      it -> shouldnt beWithin(1).of(13.0)

    context 'float delta', ->
      it -> should beWithin(0.001).of(10.0001)
      it -> shouldnt beWithin(0.001).of(10.1)

  context 'with float and integer', ->
    subject -> 22.0 / 7

    context 'integer delta', ->
      it -> should beWithin(1).of(3)
      it -> shouldnt beWithin(1).of(13)

    context 'float delta', ->
      it -> should beWithin(1.1).of(3.1)
      it -> shouldnt beWithin(1.1).of(5.0)

describe exist, ->
  context 'with something', ->
    subject -> {}

    it -> should exist

  context 'with nothing', ->
    subject -> undefined

    it -> shouldnt exist

  context 'with a falsy value', ->
    subject -> false

    it -> should exist

describe match, ->
  given 'fixturesContainer', -> document.querySelector '#fixtures'
  subject -> 'irrelevant'

  it -> should match /irrelevant/
  it -> shouldnt match /tnavelerri/

  context 'with a dom object', ->
    fixture 'sample.html'
    fixture 'sample.dom', as: 'dom'

    context 'on document', ->
      subject -> document

      it -> shouldnt match @dom

    context 'on a section node', ->
      subject -> @fixturesContainer.querySelector 'section'

      it -> should match @dom

    context 'on a section nodelist', ->
      subject -> @fixturesContainer.querySelectorAll 'section'

      it -> should match @dom

  context 'with a string', ->
    it -> should match 'irrelevant'
    it -> shouldnt match 'tnavelerri'

describe contains, ->
  given 'fixturesContainer', -> document.querySelector '#fixtures'
  subject -> [0,1,2,'foo','bar',true]

  it ->
    should contains 0
    should contains 'foo', true
    shouldnt contains 4
    shouldnt contains 'foo', false

  context 'with a dom object', ->
    fixture 'sample.html'
    fixture 'sample.dom', as: 'dom'

    context 'on document', ->
      subject -> document

      it -> should contains @dom

    context 'on a section node', ->
      subject -> @fixturesContainer.querySelector 'section'

      it -> shouldnt contains @dom

    context 'on a section nodelist', ->
      subject -> @fixturesContainer.querySelectorAll 'section'

      it -> shouldnt contains @dom

describe haveBeenCalled, ->
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

describe throwAnError, ->
  context 'on a function that throw an error', ->
    subject -> -> throw new Error 'message'

    it -> should throwAnError()
    it -> should throwAnError /message/
    it -> shouldnt throwAnError /irrelevant/

  context 'on a function that does not throw an error', ->
    subject -> ->

    it -> shouldnt throwAnError()
    it -> shouldnt throwAnError /message/

  context 'on a function that throw with arguments', ->
    subject -> -> throw new Error 'message' if arguments.length > 0

    it -> shouldnt throwAnError()
    it -> shouldnt throwAnError /message/
    it -> should throwAnError().with 'an argument'
    it -> should throwAnError(/message/).with('an argument').inContext({})

describe 'have', ->
  context 'on an object with a collection', ->
    subject -> items: [0,1,2,3], foo: 'bar'

    it -> should have 4, 'items'
    it -> shouldnt have 2, 'items'
    it -> shouldnt have 6, 'children'
    it -> shouldnt have 2, 'foo'

    runningSpecs('error raised in describe')
    .shouldFailWith /Undefined label in have matcher/, ->
      subject -> items: [0,1,2,3], foo: 'bar'

      it 'should throw an error', -> should have 2

  context 'on a collection', ->
    subject -> [0,1,2,3]

    it -> should have 4
    it -> should have 4, 'items'
    it -> should have 4, 'children'
    it -> shouldnt have 2
    it -> shouldnt have 2, 'items'

  context 'on a string', ->
    subject -> 'string'

    it -> should have 6
    it -> should have 6, 'chars'
    it -> shouldnt have 2, 'chars'

  context 'on a number', ->
    subject -> 10

    it -> shouldnt have 10, 'elements'
