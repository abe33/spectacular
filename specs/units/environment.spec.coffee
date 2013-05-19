
describe describe, ->
  runningSpecs('called in a describe block')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      describe 'bar', ->
        subject -> true
        it -> should be true

  environmentMethod('describe').cannotBeCalledInsideIt()

describe context, ->
  runningSpecs('called in a describe block')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      context 'bar', ->
        subject -> true
        it -> should be true

  environmentMethod('context').cannotBeCalledInsideIt()

describe xdescribe, ->
  runningSpecs('called at top level')
  .shouldSucceedWith /0 failures, (.*), 1 pending/, ->
    xdescribe 'pending examples', ->
      it -> fail()

  environmentMethod('xdescribe').cannotBeCalledInsideIt()

describe xcontext, ->
  runningSpecs('called at top level')
  .shouldSucceedWith /0 failures, (.*), 1 pending/, ->
    xcontext 'pending examples', ->
      it -> fail()

  environmentMethod('xcontext').cannotBeCalledInsideIt()

describe should, ->
  runningSpecs('called inside it')
  .shouldSucceedWith /1 success, 1 assertion/, ->
    describe 'foo', ->
      subject -> true
      it -> should be true

  runningSpecs('called inside it without matcher')
  .shouldSucceedWith /0 success, 0 assertions, (.*), 1 pending/, ->
    describe 'foo', ->
      subject -> true
      it -> should()

  runningSpecs('called outside it')
  .shouldStopWith /should called outside a it block/, ->
    describe 'foo', ->
      should be true

describe it, ->
  runningSpecs('called inside describe')
  .shouldSucceedWith /2 success, 2 assertion/, ->
    describe 'foo', ->
      subject -> true
      it -> should be true
      it 'with message', -> should be true

  environmentMethod('it').cannotBeCalledInsideIt()

describe the, ->
  runningSpecs('called inside describe')
  .shouldSucceedWith /2 success, 2 assertion/, ->
    describe 'foo', ->
      subject -> true
      the -> should be true
      the 'with message', -> should be true

  environmentMethod('the').cannotBeCalledInsideIt()

describe xit, ->
  runningSpecs('called inside describe')
  .shouldSucceedWith /2 pending/, ->
    describe 'foo', ->
      subject -> true
      xit -> should be true
      xit 'with message', -> should be true

  environmentMethod('xit').cannotBeCalledInsideIt()

describe withParameters, ->
  runningSpecs('called inside describe')
  .shouldSucceedWith /1 success/, ->
    f = (a) -> a
    describe f, ->
      withParameters 10

      itsReturn -> should equal 10

  environmentMethod('withParameters').cannotBeCalledInsideIt()

describe withArguments, ->
  runningSpecs('called inside describe')
  .shouldSucceedWith /1 success/, ->
    f = (a) -> a
    describe f, ->
      withArguments 10

      itsReturn -> should equal 10

  environmentMethod('withArguments').cannotBeCalledInsideIt()

describe Object, ->
  describe '::should', ->
    runningSpecs('called inside it')
    .shouldSucceedWith /1 success, 1 assertion/, ->
      describe 'foo', ->
        the -> true.should be true

    runningSpecs('called inside it without matcher')
    .shouldSucceedWith /0 success, 0 assertions, (.*), 1 pending/, ->
      describe 'foo', ->
        the -> {}.should()

    runningSpecs('called outside it')
    .shouldStopWith /should called outside a it block/, ->
      describe 'foo', ->
        {}.should be true

describe before, ->
  runningSpecs('called in describe')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      before -> @object = {}
      the -> @object.should exist

  environmentMethod('before').cannotBeCalledInsideIt()

describe after, ->
  afterCalled = false
  runningSpecs('called in describe')
  .shouldSucceedWith /1 success/, ->
    describe 'foo', ->
      after -> afterCalled = true
      the -> true.should be true

  the -> afterCalled.should be true

  environmentMethod('after').cannotBeCalledInsideIt()



