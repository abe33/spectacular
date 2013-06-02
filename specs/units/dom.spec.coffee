describe spectacular.dom.DOMParser, ->
  it -> should exist

  whenPass ->
    given 'dom', -> '''
      html
        head
        body
      '''
    withArguments -> [@dom]

    itsInstance -> should exist
    itsInstance 'source', -> should equal @dom

    describe '::match', ->
      itsReturn with: [$('html')], -> should be true

    describe '::contains', ->
      itsReturn with: [$('html')], -> should be false

