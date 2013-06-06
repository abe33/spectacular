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

    context 'when chained using then', ->
      given 'firstPromise', -> new spectacular.Promise
      given 'secondPromise', -> @firstPromise.then ->
      given 'thirdPromise', -> @secondPromise.then ->

      context 'when the first promise is fulfilled', ->
        before -> @firstPromise.resolve()

        specify 'the secondPromise', -> @secondPromise.should be 'fulfilled'
        specify 'the thirdPromise', -> @thirdPromise.should be 'fulfilled'

      context 'when the first promise is rejected', ->
        before -> @firstPromise.reject('message')

        specify 'the secondPromise', -> @secondPromise.should be 'rejected'
        specify 'the thirdPromise', -> @thirdPromise.should be 'rejected'

      context 'and one of the factory return a promise', ->
        given 'firstPromise', -> new spectacular.Promise
        given 'returnedPromise', -> new spectacular.Promise
        given 'secondPromise', -> @firstPromise.then => @returnedPromise
        given 'thirdPromise', -> @secondPromise.then ->

        context 'when the first promise is fulfilled', ->
          before -> @firstPromise.resolve()

          specify 'the secondPromise', -> @secondPromise.shouldnt be 'fulfilled'
          specify 'the thirdPromise', -> @thirdPromise.should be 'pending'

          context 'and the returned promise is fulfilled', ->
            before -> @returnedPromise.resolve()

            specify 'the secondPromise', -> @secondPromise.should be 'fulfilled'
            specify 'the thirdPromise', -> @thirdPromise.should be 'fulfilled'

          context 'and the returned promise is rejected', ->
            before -> @returnedPromise.reject('message')

            specify 'the secondPromise', -> @secondPromise.should be 'rejected'
            specify 'the thirdPromise', -> @thirdPromise.should be 'rejected'

        context 'when the first promise is rejected', ->
          before -> @firstPromise.reject('message')

          specify 'the secondPromise', -> @secondPromise.should be 'rejected'
          specify 'the thirdPromise', -> @thirdPromise.should be 'rejected'

