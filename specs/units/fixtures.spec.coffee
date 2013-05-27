describe fixture, ->
  it -> should exist

  context 'for a json file', ->
    context 'inside a context', ->
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

    context 'inside a context with a name', ->
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
