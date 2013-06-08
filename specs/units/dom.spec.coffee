describe spectacular.dom.DOMExpression, ->
  fixture 'sample.html'
  it -> should exist

  whenPass ->
    given 'dom', -> '''
      html
        head
        body
          section
            header
              h1
                'title'
            article
              h3
                'article title'
              p
                /article content/

            footer
      '''
    withArguments -> [@dom]

    itsInstance -> should exist
    itsInstance 'source', -> should equal @dom

    describe '::match', ->
      itsReturn with: (-> [document.querySelector 'html']), -> should be true
      itsReturn with: (-> [document.querySelector '#fixtures section']), ->
        should be false
      itsReturn with: (-> [document.querySelectorAll 'section']), ->
        should be false

    describe '::contained', ->
      itsReturn with: (-> [document.querySelector 'html']), -> should be false

      context 'with a dom looking for node content', ->
        given 'dom', -> '''
          article
            h3
              'article title'
            p
              /article.*content/
          '''

        itsReturn with: (-> [document]), -> should be true

      context 'with a dom failing after a negative indent', ->
        given 'dom', -> '''
          article
            h3
              'article title'
            p
              /article.*foo/
          '''

        itsReturn with: (-> [document]), -> should be false

    context 'with an invalid dom', ->
      subject -> => new spectacular.dom.DOMExpression @dom

      context 'due to an invalid root indent', ->
        given 'dom', -> '  html'

        it -> should throwAnError(/invalid indent on line 1/)

      context 'due to an invalid nested indent', ->
        given 'dom', -> 'html\n    head'

        it -> should throwAnError(/invalid indent on line 2/)

      context 'due to an incomplete indent', ->
        given 'dom', -> 'html\n head'

        it -> should throwAnError(/invalid indent on line 2/)

      context 'due to a child for text expression', ->
        given 'dom', -> 'html\n  "text"\n    div'

        it -> should throwAnError(/text expressions cannot have children on line 3/)
