describe spectacular.Promise, ->

  it -> should exist

  whenPass ->
    itsInstance -> should exist

    describe '.unit', ->
      it -> should exist
      whenPass ->
        itsReturn -> should exist

        context 'the returned promise', ->
          subject 'promise', -> spectacular.Promise.unit()

          it -> should be 'fulfilled'
          its 'value', -> should equal 0

        context 'when called with a value', ->
          subject 'promise', -> spectacular.Promise.unit('foo')

          it -> should be 'fulfilled'
          its 'value', -> should equal 'foo'


    describe '.all', ->
      it -> should exist

      whenPass ->
        context 'when called with an array of promise', ->
          withParameters [
            spectacular.Promise.unit()
            spectacular.Promise.unit()
            spectacular.Promise.unit()
          ]

          itsReturn -> should exist
          itsReturn -> should be 'fulfilled'

    describe '::isPending', ->
      itsReturn -> should equal true
