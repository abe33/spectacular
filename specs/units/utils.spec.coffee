describe spectacular.utils.escape, ->
  context 'called with html content', ->
    withArguments '<tag>content</tag>'

    itsReturn -> should equal '&lt;tag&gt;content&lt;/tag&gt;'

describe spectacular.utils.escapeDiff, ->
  context 'called with html content', ->
    withArguments '<tag><del>con</del><ins>tent</ins></tag>'

    itsReturn ->
      should equal '&lt;tag&gt;<del>con</del><ins>tent</ins>&lt;/tag&gt;'

describe spectacular.utils.unescape, ->
  context 'called with html content', ->
    withArguments '&lt;tag&gt;content&lt;/tag&gt;'

    itsReturn -> should equal '<tag>content</tag>'

describe spectacular.utils.squeeze, ->
  context 'called with a string several consecutives spaces', ->
    withArguments 'a string    with\n\t   spaces'

    itsReturn -> should equal 'a string with spaces'

describe spectacular.utils.fill, ->
  context 'when called without any arguments', ->
    itsReturn -> should equal '    '

  context 'when called with only a length', ->
    withArguments 10

    itsReturn -> should equal '          '

  context 'when called with both arguments', ->
    withArguments 10, '0'

    itsReturn -> should equal '0000000000'

describe spectacular.utils.indent, ->
  context 'when called with a multiline string', ->
    withArguments 'line1\nline2\nline3'

    itsReturn -> should equal '    line1\n    line2\n    line3'

describe spectacular.utils.stringDiff, ->
  context 'with null as first argument', ->
    withArguments null, 'foo'

    itsReturn -> should equal spectacular.utils.ins 'foo'

  context 'with null as second argument', ->
    withArguments 'foo'

    itsReturn -> should equal spectacular.utils.del 'foo'
