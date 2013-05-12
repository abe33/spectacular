describe spectacular.Promise, ->

  it -> should exist
  itsInstance -> should exist

  it 'should fail', (async) ->
  it 'should fail', -> fail()
  it 'should be pending', -> pending()
  it 'should be skipped', -> skip()
  it 'should succeed', -> success()

  describe '.unit', ->
    it -> should exist
    itsReturn -> should exist

    it 'should returns a new fulfilled promise', ->
      @returnedValue.should be 'fulfilled'
      @returnedValue.value.should equal 0

  describe '.all', ->
    it -> should exist

    context 'when called with an array of promise', ->
      withParameters [
        spectacular.Promise.unit()
        spectacular.Promise.unit()
        spectacular.Promise.unit()
      ]

      itsReturn -> should exist
      itsReturn -> should be 'fulfilled'

      it 'fail due to nested it', ->
        it 'should not be run', ->
