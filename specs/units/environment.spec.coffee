
describe describe, ->
  runningSpecs('call in a describe block')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      describe 'bar', ->
        subject -> true
        it -> should be true

  environmentMethod('describe').cannotBeCalledInsideIt()

describe context, ->
  runningSpecs('call in a describe block')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      context 'bar', ->
        subject -> true
        it -> should be true

  environmentMethod('context').cannotBeCalledInsideIt()

describe xdescribe, ->
  runningSpecs('call at top level')
  .shouldSucceedWith /0 failures, (.*), 1 pending/, ->
    xdescribe 'pending examples', ->
      it -> fail()

  environmentMethod('xdescribe').cannotBeCalledInsideIt()

describe xcontext, ->
  runningSpecs('call at top level')
  .shouldSucceedWith /0 failures, (.*), 1 pending/, ->
    xcontext 'pending examples', ->
      it -> fail()

  environmentMethod('xcontext').cannotBeCalledInsideIt()

describe should, ->
  runningSpecs('call inside it')
  .shouldSucceedWith /1 success, 1 assertion/, ->
    describe 'foo', ->
      subject -> true
      it -> should be true

  runningSpecs('call outside it')
  .shouldStopWith /should called outside a it block/, ->
    describe 'foo', ->
      should be true

  environmentMethod('should').cannotBeCalledWithoutMatcher()

describe it, ->
  runningSpecs('call inside describe')
  .shouldSucceedWith /2 success, 2 assertion/, ->
    describe 'foo', ->
      subject -> true
      it -> should be true
      it 'with message', -> should be true

  environmentMethod('it').cannotBeCalledInsideIt()

describe the, ->
  runningSpecs('call inside describe')
  .shouldSucceedWith /2 success, 2 assertion/, ->
    describe 'foo', ->
      subject -> true
      the -> should be true
      the 'with message', -> should be true

  environmentMethod('the').cannotBeCalledInsideIt()

describe xit, ->
  runningSpecs('call inside describe')
  .shouldSucceedWith /2 pending/, ->
    describe 'foo', ->
      subject -> true
      xit -> should be true
      xit 'with message', -> should be true

  environmentMethod('xit').cannotBeCalledInsideIt()

describe withParameters, ->
  runningSpecs('call inside describe')
  .shouldSucceedWith /1 success/, ->
    f = (a) -> a
    describe f, ->
      withParameters 10

      itsReturn -> should equal 10

  environmentMethod('withParameters').cannotBeCalledInsideIt()

describe withArguments, ->
  runningSpecs('call inside describe')
  .shouldSucceedWith /1 success/, ->
    f = (a) -> a
    describe f, ->
      withArguments 10

      itsReturn -> should equal 10

  environmentMethod('withArguments').cannotBeCalledInsideIt()

describe Object, ->
  describe '::should', ->
    runningSpecs('call inside it')
    .shouldSucceedWith /1 success, 1 assertion/, ->
      describe 'foo', ->
        the -> true.should be true

    runningSpecs('call inside it without matcher')
    .shouldSucceedWith /0 success, 0 assertions, (.*), 1 pending/, ->
      describe 'foo', ->
        the -> {}.should()

    runningSpecs('call outside it')
    .shouldStopWith /should called outside a it block/, ->
      describe 'foo', ->
        {}.should be true

describe before, ->
  runningSpecs('call in describe')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      before -> @object = {}
      the -> @object.should exist

  environmentMethod('before').cannotBeCalledInsideIt()

describe after, ->
  afterCalled = false
  runningSpecs('call in describe')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      after -> afterCalled = true
      the -> true.should be true

  the -> afterCalled.should be true

  environmentMethod('after').cannotBeCalledInsideIt()

describe withParameters, ->
  environmentMethod('withParameters').cannotBeCalledInsideIt()

describe withArguments, ->
  environmentMethod('withArguments').cannotBeCalledInsideIt()

describe dependsOn, ->
  environmentMethod('dependsOn').cannotBeCalledInsideIt()

describe whenPass, ->
  environmentMethod('whenPass').cannotBeCalledInsideIt()

describe fixture, ->
  environmentMethod('fixture').cannotBeCalledInsideIt()

describe spyOn, ->
  environmentMethod('spyOn').cannotBeCalledOutsideIt()

describe itsReturn, ->
  environmentMethod('itsReturn').cannotBeCalledInsideIt()
  environmentMethod('itsReturn').cannotBeCalledWithoutPreviousSubject()

describe itsInstance, ->
  environmentMethod('itsInstance').cannotBeCalledInsideIt()
  environmentMethod('itsInstance').cannotBeCalledWithoutPreviousSubject()

  context 'with a class that takes arguments in constructor', ->
    subject ->
      class Foo
        constructor: (@a, @b) ->

    itsInstance with: [0,1], -> should exist
    itsInstance 'a', with: [0,1], -> should equal 0
    itsInstance 'b', with: [0,1], -> should equal 1

runningSpecs('inner example alias').
shouldSucceedWith /1 success/, ->
  spectacular.env.createInnerExampleAlias 'may', 'should'

  describe 'foo', ->
    subject -> true

    it -> may be true
