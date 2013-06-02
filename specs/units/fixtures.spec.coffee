describe fixture, ->
  it -> should exist

  context 'for a json file', ->
    context 'without a name', ->
      fixture 'sample.json'

      subject -> @fixture

      it -> should exist
      it -> should equal
        string: 'irrelevant'
        object:
          a: 'aaa'
          b: 'bbb'
          c: 'ccc'
        array: [10, 'foo', true]
        number: 10
        boolean: true

    context 'with a name', ->
      fixture 'sample.json', as: 'sample'

      subject -> @sample

      it -> should exist
      it -> should equal
        string: 'irrelevant'
        object:
          a: 'aaa'
          b: 'bbb'
          c: 'ccc'
        array: [10, 'foo', true]
        number: 10
        boolean: true

  context 'for an html file', ->
    fixture 'sample.html'

    specify 'the dom', ->
      $('body').should have.selector '#section'

    specify 'the fixture', ->
      @fixture.should exist
      @fixture.should have.selector 'article'

  context 'for a dom file', ->
    fixture 'sample.html'
    fixture 'sample.dom', as: 'dom'
    subject -> @dom

    it -> should exist

    context 'the dom expression', ->
      subject -> $('html')

      it -> shouldnt match @dom
      it -> should contains @dom

      context 'on a matching element', ->
        subject -> $('#section')

        it -> should match @dom
        it -> shouldnt contains @dom



