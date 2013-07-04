class MixinWithIncludedHook
  @included: (cls) -> cls::otherProperty = 'also irrelevant'
  property: 'irrelevant'

class MixinWithoutIncludedHook
  property: 'irrelevant'

class MixinWithExcludedProperty
  property: 'irrelevant'
  otherProperty: 'also irrelevant'
  excluded: ['otherProperty']

class MixinWithExtendedHook
  @extended: (cls) -> cls.otherProperty = 'also irrelevant'
  @property: 'irrelevant'

class MixinWithoutExtendedHook
  @property: 'irrelevant'

class MixinWithExcludedClassProperty
  @property: 'irrelevant'
  @otherProperty: 'also irrelevant'
  @excluded: ['otherProperty']

class ConcernWithIncludedAndExcluded
  @included: (cls) -> cls::otherProperty = 'also irrelevant'
  @extended: (cls) -> cls.otherProperty = 'also irrelevant'
  @property: 'irrelevant'
  property: 'irrelevant'

class ConcernWithExcludedHook
  @property: 'irrelevant'
  @otherProperty: 'also irrelevant'

  property: 'irrelevant'
  otherProperty: 'also irrelevant'

  @excluded: ['otherProperty']
  excluded: ['property']

describe Function, ->
  given 'dummy', -> class DummyClass

  describe '::include', ->
    context 'with a mixin that do not define the included hook', ->
      before -> @dummy.include MixinWithoutIncludedHook
      subject -> new @dummy

      its 'property', -> should equal 'irrelevant'

    context 'with a mixin that define the included hook', ->
      before -> @dummy.include MixinWithIncludedHook
      subject -> new @dummy

      its 'property', -> should equal 'irrelevant'
      its 'otherProperty', -> should equal 'also irrelevant'

    context 'with a mixin that define the excluded hook', ->
      before -> @dummy.include MixinWithExcludedProperty
      subject -> new @dummy

      its 'property', -> should equal 'irrelevant'
      its 'otherProperty', -> shouldnt exist

  describe '::extend', ->
    context 'with a mixin that do not define the extended hook', ->
      before -> @dummy.extend MixinWithoutExtendedHook
      subject -> @dummy

      its 'property', -> should equal 'irrelevant'

    context 'with a mixin that define the extended hook', ->
      before -> @dummy.extend MixinWithExtendedHook
      subject -> @dummy

      its 'property', -> should equal 'irrelevant'
      its 'otherProperty', -> should equal 'also irrelevant'

    context 'with a mixin that define the excluded hook', ->
      before -> @dummy.extend MixinWithExcludedClassProperty
      subject -> @dummy

      its 'property', -> should equal 'irrelevant'
      its 'otherProperty', -> shouldnt exist

  describe '::concern', ->
    context 'with a concern that defines both hooks', ->
      before -> @dummy.concern ConcernWithIncludedAndExcluded
      subject -> @dummy

      its 'property', -> should equal 'irrelevant'
      its 'otherProperty', -> should equal 'also irrelevant'

      context 'its instance', ->
        subject -> new @dummy

        its 'property', -> should equal 'irrelevant'
        its 'otherProperty', -> should equal 'also irrelevant'

    context 'with a concern that defines exclusion for both', ->
      before -> @dummy.concern ConcernWithExcludedHook
      subject -> @dummy

      its 'property', -> should equal 'irrelevant'
      its 'otherProperty', -> shouldnt exist

      context 'its instance', ->
        subject -> new @dummy

        its 'otherProperty', -> should equal 'also irrelevant'
        its 'property', -> shouldnt exist

  describe '::getter', ->
    context 'on a child class that overrides an accessor', ->
      given 'Parent', ->
        class Parent
          @accessor 'foo', {
            get: -> @_foo
            set: (value) -> @_foo = value
          }
      given 'Child', ->
        class Child extends @Parent
          @getter 'foo', -> 'BAR'

      subject -> new @Child

      specify 'the child instance getter return', ->
        @subject.foo.should equal 'BAR'

      context 'the child instance setter called', ->
        before -> @subject.foo = 'FOO'

        specify 'the private var', ->
          expect(@subject._foo).to equal 'FOO'

  describe '::setter', ->
    context 'on a child class that overrides an accessor', ->
      given 'Parent', ->
        class Parent
          @accessor 'foo', {
            get: -> 'foo'
            set: (value) -> @_foo = value
          }
      given 'Child', ->
        class Child extends @Parent
          @setter 'foo', -> @_foo = 'BAR'

      subject -> new @Child

      specify 'the child instance getter return', ->
        expect(@subject.foo).to equal 'foo'

      context 'the child instance setter called', ->
        before -> @subject.foo = 'FOO'

        specify 'the private var', ->
          expect(@subject._foo).to equal 'BAR'

