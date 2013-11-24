---
title: Extending Spectacular
date: 2013-07-17 20:26
author: Cédric Néhémie <cedric.nehemie@gmail.com>
template: page.jade
----

## Snake Case Syntax

All the exposed methods are provided both with `camelCase` and `snake_case` syntax. By convention, JavaScript use the camel case form, but some people writing CoffeeScript for nodejs often use the snake case form. Spectacular support both.

You can define any matcher, or helper, or aliases, with either the snake case
or camel case form, the alternative will be also added to the global object.

For instance, the `sharedExample` is also available through `shared_example`.

You can find below a table with all the snake case equivalent:

<table cellspacing="0">
    <tr><td>`after`</td><td>No differences</td></tr>
    <tr><td>`before`</td><td>No differences</td></tr>
    <tr><td>`beWithin`</td><td>`be_within`<td></tr>
    <tr><td>`chain`</td><td>No differences</td></tr>
    <tr><td>`contains`</td><td>No differences</td></tr>
    <tr><td>`context`</td><td>No differences</td></tr>
    <tr><td>`createWith`</td><td>`create_with`</td></tr>
    <tr><td>`dependsOn`</td><td>`depends_on`</td></tr>
    <tr><td>`describe`</td><td>No differences</td></tr>
    <tr><td>`description`</td><td>No differences</td></tr>
    <tr><td>`equal`</td><td>No differences</td></tr>
    <tr><td>`exist`</td><td>No differences</td></tr>
    <tr><td>`expect`</td><td>No differences</td></tr>
    <tr><td>`factory`</td><td>No differences</td></tr>
    <tr><td>`factoryMixin`</td><td>`factory_mixin`</td></tr>
    <tr><td>`fail`</td><td>No differences</td></tr>
    <tr><td>`failureMessageForShould`</td><td>`failure_message_for_should`</td></tr>
    <tr><td>`failureMessageForShouldnt`</td><td>`failure_message_for_shouldnt`</td></tr>
    <tr><td>`fixturePath`</td><td>`fixture_path`</td></tr>
    <tr><td>`fixtures`</td><td>No differences</td></tr>
    <tr><td>`given`</td><td>No differences</td></tr>
    <tr><td>`have.selector`</td><td>No differences</td></tr>
    <tr><td>`have`</td><td>No differences</td></tr>
    <tr><td>`haveBeenCalled.with`</td><td>`have_been_called.with`</td></tr>
    <tr><td>`haveBeenCalled`</td><td>`have_been_called`</td></tr>
    <tr><td>`it`</td><td>No differences</td></tr>
    <tr><td>`itBehavesLike`</td><td>`it_behaves_like`</td></tr>
    <tr><td>`its`</td><td>No differences</td></tr>
    <tr><td>`itShould`</td><td>`it_should`</td></tr>
    <tr><td>`itsInstance`</td><td>`its_instance`</td></tr>
    <tr><td>`itsReturn`</td><td>`its_return`</td></tr>
    <tr><td>`match`</td><td>No differences</td></tr>
    <tr><td>`match`</td><td>No differences</td></tr>
    <tr><td>`pending`</td><td>No differences</td></tr>
    <tr><td>`registerFixtureHandler`</td><td>`register_fixture_handler`</td></tr>
    <tr><td>`set`</td><td>No differences</td></tr>
    <tr><td>`should`</td><td>No differences</td></tr>
    <tr><td>`shouldnt`</td><td>No differences</td></tr>
    <tr><td>`skip`</td><td>No differences</td></tr>
    <tr><td>`specify`</td><td>No differences</td></tr>
    <tr><td>`spy.argsForCall`</td><td>`spy.args_for_call`</td></tr>
    <tr><td>`spyOn(...).andCallFake`</td><td>`spy_on(...).and_call_fake`</td></tr>
    <tr><td>`spyOn(...).andCallThrough`</td><td>`spy_on(...).and_call_trough`</td></tr>
    <tr><td>`spyOn(...).andReturns`</td><td>`spy_on(...).and_returns`</td></tr>
    <tr><td>`spyOn`</td><td>`spy_on`</td></tr>
    <tr><td>`subject`</td><td>No differences</td></tr>
    <tr><td>`success`</td><td>No differences</td></tr>
    <tr><td>`takes`</td><td>No differences</td></tr>
    <tr><td>`the`</td><td>No differences</td></tr>
    <tr><td>`throwAnError(msg).inContext`</td><td>`throw_an_error(msg).in_context`</td></tr>
    <tr><td>`throwAnError(msg).with`</td><td>`throw_an_error(msg).with`</td></tr>
    <tr><td>`throwAnError`</td><td>`throw_an_error`</td></tr>
    <tr><td>`trait`</td><td>No differences</td></tr>
    <tr><td>`whenPass`</td><td>`when_pass`</td></tr>
    <tr><td>`withArguments`</td><td>`with_arguments`</td></tr>
    <tr><td>`withParameters`</td><td>`with_parameters`</td></tr>
    <tr><td>`xcontext`</td><td>No differences</td></tr>
    <tr><td>`xdescribe`</td><td>No differences</td></tr>
    <tr><td>`xit`</td><td>No differences</td></tr>
</table>

You can also snakify/camelize your own objects using the `utils.snakify` or `utils.camelize` methods:

```coffeescript
myObject =
  someMethod: ->
  someOtherMethod: ->

utils.snakify myObject
```

Will gives you an object such as:

```coffeescript
myObject =
  someMethod: ->
  someOtherMethod: ->
  some_method: ->
  some_other_method: ->
```

<aside>
  <p>Note that when using the `spectacular.matcher` and `spectacular.helper` methods the defined matcher/helper is automatically converted to either its camel or snake case alternative.</p>
</aside>

## Matchers

Matchers are defined with the `spectacular.matcher` function. It generates an object with a `match` method that should return a boolean value corresponding to the assertion result.

```coffeescript
spectacular.matcher 'returnSomething', ->
  match (actual) -> actual() isnt null

  description -> "return something"

  failureMessageForShould message = "Expected #{@actual} to #{@description}"

# Usage:
it -> should returnSomething
```

The matcher receive a string containing `' not'` if the matcher was passed to `shouldnt` or `expect(...).not.to`.

If an exception is raised during the matcher execution, the example will be marked as `errored` instead of `failure`.

You can create parameterizable matcher by calling the `takes` function in the matcher definition block.

```coffeescript
spectacular.matcher 'parameterizableMatcher', ->
  takes 'value1', 'value2'

  match -> @value1 and @value2

  description -> 'parameterizableMatcher description'

  failureMessageForShould -> 'parameterizableMatcher message'

# Usage:
it -> should parameterizableMatcher(value1, value2)
```

The parameters defined with takes are then stored in the matcher instance with the provided names. The `takes` function accept a slat argument such as `values...`. In that case, the splat must be the sole argument.

<aside>
  <p>**Note:** Matchers that doesn't takes arguments are created only once and
  then passed to the expectation, they should never stores anything that may induce false positive in later tests.</p>
  <p>This is not an issue with parameterizable matchers since an instance is created every time the matcher function is called.</p>
</aside>

It's possible to run code on the initialization of a matcher:

```coffeescript
spectacular.matcher 'matcherWithInit', ->
  init -> # do some setup such creating composed objects

  match (actual) -> @composedObject.match actual

  description -> 'matcher with init description'

  failureMessageForShould -> 'matcher with init message'

# Usage:
it -> should matcherWithInit(value1, value2)
```

You can also add chaining methods with the `chain` function:

```coffeescript
spectacular.matcher 'chainableMatcher', ->
  takes 'value1'

  chain 'with', (@value2) ->

  match -> @value1 and @value2

  description -> 'chainableMatcher description'

  failureMessageForShould -> 'chainableMatcher message'

# Usage:
it -> should chainableMatcher(value1).with(value2)
```

## Asynchronous Matchers

Matchers can be asynchronous, in that case they should return a promise instead of a boolean value. The default timeout for asynchronous matchers is 5000ms, it can be changed by setting the `timeout` in the matcher block.

```coffeescript
spectacular.matcher 'asyncMatcher', ->
  timeout 1000
  match (actual, notText) ->

    promise = new spectacular.Promise

    setTimeout (-> promise.resolve actual isnt null), 100

    promise

  description -> 'should match asynchronously'
  failureMessageForShould -> 'Expected to match asynchronously'
```
If the promise is rejected, the example is marked as `errored`.

<aside>
  <p>**Note:** Asynchronous matcher should be used carefully and never meddled with synchronous code, a good example of case to avoid can be found below</p>

<pre class='coffeescript'>`specify 'several assertions in an example', ->
  expect(object).to anAsynchronousMatcher 'foo', 'bar'
  object.foo = 'baz'
  expect(object).to anAsynchronousMatcher 'foo', 'baz'`</pre>

  <p>In that case the object property's value may have changed when the test is performed by the matcher.</p>
</aside>

## Fixtures Handlers

Spectacular support by default 3 fixtures format: `json`, `html` and `dom`.

However you can quickly extend Spectacular with new fixtures handlers using the `registerFixtureHandler`:

```coffeescript
registerFixtureHandler 'ext', (content) ->
  # do something with the content
```

The value returned by the handler block will be used as the fixture in specs.
