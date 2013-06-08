
describe 'spyOn', ->
  given 'object', -> method: -> 42

  context 'used to spy on a method', ->
    before -> @spy = spyOn @object, 'method'
    subject -> @spy

    context 'the returned spy', ->
      it -> should exist
      it -> should be 'the object method', @object.method

    context 'calling the spied function', ->
      before ->
        @spy
        @result = @object.method('foo', 10)

      it 'should have registered the passed arguments', ->
        @spy.argsForCall.should equal [['foo', 10]]
        @object.method.argsForCall.should equal [['foo', 10]]

      it 'should have called through', ->
        @result.should be 42

  describe '::andCallFake', ->
    context 'used to mock a method', ->
      before -> @spy = spyOn(@object, 'method').andCallFake -> 0
      subject -> @spy

      context 'the returned spy', ->
        it -> should exist
        it -> should be 'the object method', @object.method

      context 'calling the mocked function', ->
        before ->
          @spy
          @result = @object.method('foo', 10)

        it 'should have registered the passed arguments', ->
          @spy.argsForCall.should equal [['foo', 10]]
          @object.method.argsForCall.should equal [['foo', 10]]

        it 'should have called the fake', ->
          @result.should be 0

  describe '::andReturns', ->
    context 'used to mock a method', ->
      before -> @spy = spyOn(@object, 'method').andReturns 10
      subject -> @spy

      context 'the returned spy', ->
        it -> should exist
        it -> should be 'the object method', @object.method

      context 'calling the mocked function', ->
        before ->
          @spy
          @result = @object.method('foo', 10)

        it 'should have registered the passed arguments', ->
          @spy.argsForCall.should equal [['foo', 10]]
          @object.method.argsForCall.should equal [['foo', 10]]

        it 'should have called the fake', ->
          @result.should be 10

  describe '::andCallThrough', ->
    context 'used to spy on a method', ->
      before -> @spy = spyOn(@object, 'method').andCallThrough (res) ->
        res * 2

      subject -> @spy

      context 'the returned spy', ->
        it -> should exist
        it -> should be 'the object method', @object.method

      context 'calling the spied function', ->
        before ->
          @spy
          @result = @object.method('foo', 10)

        it 'should have registered the passed arguments', ->
          @spy.argsForCall.should equal [['foo', 10]]
          @object.method.argsForCall.should equal [['foo', 10]]

        it 'should have called the spied method and the block', ->
          @result.should be 84






