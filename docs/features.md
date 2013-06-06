### Features List

  1. Priorized specs: Some specs may run before others and prevent the following specs to run if one failure arise:

    ```coffeescript
    describe 'dependency example', id: 'dependency', ->
      it -> fail()

    describe 'dependent', ->
      # Run only if the specs in 'dependency' all passed
      # By default the runner will lookup for specs in the same file, and
      # raise an issue if the spec can't be found.
      dependsOn 'dependency'

      it 'will be marked as skipped', ->
        # ...

    ```

    This feature allow to fail fast when lower level specs fails such as with Models > Controllers > Views. If models specs fails the controllers and views specs aren't run.

  2. Cascading specs: Prevent deeper specs from being executed if any of the specs in the parent level fails:

    ```coffeescript
    describe 'Top level specs', ->
      it -> fail()

      context 'deeper specs running whatever the results of top level', ->
        # ...

      whenPass ->
        context 'deeper specs that will run only if top level is green', ->
          # ...
    ```
    This feature allow to fail fast in *scenario* specs. Each nested describe block is a new branch of the testing process. And each branch's steps are only tested if the previous step was resolved with a success. As in:

    ```coffeescript
    context 'when clicking on the submit button', ->
      given 'results', -> data: 'value'
      given 'formURL', -> '/my/api/url'
      before 'each', ->
        spyOn($, 'ajax').andCallFake (url, opts) => opts.success? @results
        spyOn(@formHandler, 'handleResults')
        @button.click()

      it 'should have performed an ajax request', ->
        $.ajax.should haveBeenCalled.with @formURL

      it 'should have registered the results handler', ->
        @formHandler.handleResults.should haveBeenCalled

      whenPass ->
        context 'after having received the request response', ->
          it 'should display the results on the page', ->
            # ...
    ```

  3. Implicit subjects: It's possible to express expectations without specifying the subject explicitely in the expectation block. Such as:

    ```coffeescript
    subject 'namedSubject', -> {elements: [0,1,2]}

    it -> should have 2, 'elements'
    its 'elements', -> shouldnt be 'empty'

    it 'should be accessible through the provided name', ->
      @namedSubject.should have 2, 'elements'

    it 'should be accessible through subject', ->
      @subject.should have 2, 'elements'
    ```

  4. Smart describe:
    * When a function is passed to describe as both arguments the first is used to create a test subject.
    * When a string starting with `.` is passed as the first argument, it defines the subject with the results of calling the corresponding class method.
    * When a string starting with `::` is passed as the first argument, it defines the subject with the results of calling the corresponding instance method.

    ```coffeescript
    describe AClass, ->
      withArguments a, b, c

      # subject here is the class constructor function
      it -> should exist

      whenPass ->
        describe '.someClassMethod', ->
          context 'called with some parameters', ->
            withArguments 10

            # subject is now the result of calling AClass.someMethod(10)
            itsReturn -> should equal 20

        # Automatically create an instance with the provided parameters as subject
        itsInstance -> should exist

        whenPass ->
          describe '::someInstanceMethod', ->
            context 'called with some parameters', ->
              withArguments 'foo'

              # subject is now the result of calling new Aclass(a,b,c).someInstanceMethod('foo')
              itsReturn -> should equal 'oof'
    ```

    The `context` method is just an alias of the `describe` method used to make explicit that the block describe a specific context and not the subject.

  5. Built-in spies and mocks (jasmine style):

    ```coffeescript
    before 'each', ->
      # Intercepts the returned value of the spied method call and passed
      # it to the provided method
      spy = spyOn(object, 'method').andCallThrough (result) ->

      # Mock the call to the method with another one.
      spy = spyOn(object, 'method').andCallFake (args...) ->

      # Mock the call to the method by returning the given value
      spy = spyOn(object, 'method').andReturns(value)
    ```

  6. Built-in promise based asynchronous specs, setup and teardown:

    ```coffeescript
    before (async) ->
      async.rejectAfter 1000, 'timeout message'

      runAsyncSetup ->
        async.resolve()

    after (async) ->
      async.rejectAfter 1000, 'timeout message'

      runAsyncTeardown ->
        async.resolve()

    it 'should run asynchronous specs', (async) ->
      async.rejectAfter 1000, 'timeout message'

      runAsyncFunction ->
        # expectations here
        async.resolve()
    ```

    Every it block defining an argument will receive a deferred promise to resolve. The promise define automatically a timeout of 5s but can be changed with `rejectAfter`. If the promise passed to the block is rejected, either by a timout or a call to `async.reject`, the examples wil be flagged as errored.

  7. Matcher based spec description:

    ```coffeescript
    describe 'an object', ->
      it -> should have 2, 'elements'
      # 'an object should have 2 elements'
    ```
    When `should` is called the description of the expectation is retrieved from the passed-in matcher.

  8. `Object.prototype` decoration (HERESY!):

    ```coffeescript
    it 'should do something', ->
      @subject.should equal 10
      'string'.shouldnt match /foo/
    ```

  9. Native objects factory:

    ```coffeescript
    given 'someObject', -> create 'myFactory', 'trait1', 'trait2', property: value
    ```

    The factory being defined with:

    ```coffeescript
    factory 'myFactory', ->
      set 'property', -> 'value'

      trait 'trait', ->
        set 'otherProperty', 'other value'
    ```

  10. Native fixtures

    ```coffeescript
    describe 'a spec with fixture', ->
      fixture 'fixture.json'

      it 'should match the fixture', ->
        @subject.should equal @fixture

    describe 'a spec with a named fixture', ->
      fixture 'fixture.json', as: 'myFixture'

      it 'should match the fixture', ->
        @subject.should equal @myFixture
    ```

    Fixtures are defined as an asynchronous before.

    According to the file extension the `fixture` helper will perform differently:
      * With a `json` extension the file is loaded then passed to `JSON.parse`
      * With a `html` extension the file is loaded then passed to `jsdom` (on nodejs) or injected into the DOM (and thus removed after the specs)
      * With a `dom` extension the file is load and then used to construct a HTML spec (see below).

  11. Built-in DOM spec tools:

    DOM specs are written using a small DSL that use CSS-queries syntax to define a DOM structure:

    ```css
    #container
      form
        input[type=text]
        a.help
          'Link content'
        input[type=submit]
        p
          /paragraph\s+(content)/
    ```

    Writing this in a file and loading it through the `fixture` function will create a `DomExpression` object
    that can be passed to the `match` and `contains` matchers:

    ```coffeescript
    describe 'a test with a dom fixture', ->
      fixture 'my_dom_expression.dom', as: 'myExpression'

      subject -> $('#container')

      it -> should match @myExpression
      it -> shouldnt contains myExpression
    ```

  12. `xdescribe`, `xcontext`, `xit`, `fail`, `skip` and `pending` methods
    * Both `xdescribe` and `xcontext` disable execution of inner specs.
    * `xit` make the corresponding spec as pending.
    * `fail` called from inside a `it` block force the spec to fail.
    * `skip` called from inside a `it` block force the spec to be skipped.
    * `pending` called from inside a `it` block force the spec as pending.

  13. Inclusives and exclusives tests:

    * `only` : when at leat one test was flagged using the `only` function, only these tests will be run.
    * `except`: all tests flagged using the `except` function will not be executed, unlike pending and skipped examples the inclusive aren't reported in the final results.

    ```coffeescript
    only describe 'a test suite', -> # exclusive test suite
    only it 'should do something', -> # exclusive test

    except describe 'a test suite', -> # inclusive test suite
    except it 'should not do something', -> # inclusive test
    ```

