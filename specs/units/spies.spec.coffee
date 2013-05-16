
describe 'spyOn', ->
  given 'object', -> method: -> 42

  context 'used to spy on a method', ->
    before -> @spy = spyOn @object, 'method'
    subject -> @spy

    context 'the returned spy', ->
      it -> should exist
      it -> should be @object.method

    context 'calling the spied function', ->
      before ->
        @spy
        @result = @object.method('foo', 10)

      it 'should have registered the passed arguments', ->
        @spy.argsForCall.should equal [['foo', 10]]
        @object.method.argsForCall.should equal [['foo', 10]]

      it 'should have called through', ->
        @result.should be 42

  context 'used to mock a method', ->
    before -> @spy = spyOn(@object, 'method').andCallFake -> 0
    subject -> @spy

    context 'the returned spy', ->
      it -> should exist
      it -> should be @object.method

    context 'calling the mocked function', ->
      before ->
        @spy
        @result = @object.method('foo', 10)

      it 'should have registered the passed arguments', ->
        @spy.argsForCall.should equal [['foo', 10]]
        @object.method.argsForCall.should equal [['foo', 10]]

      it 'should have called the fake', ->
        @result.should be 0

    context 'with andReturns', ->
      before -> @spy = spyOn(@object, 'method').andReturns 10

      context 'the returned spy', ->
        it -> should exist
        it -> should be @object.method

      context 'calling the mocked function', ->
        before ->
          @spy
          @result = @object.method('foo', 10)

        it 'should have registered the passed arguments', ->
          @spy.argsForCall.should equal [['foo', 10]]
          @object.method.argsForCall.should equal [['foo', 10]]

        it 'should have called the fake', ->
          @result.should be 10
