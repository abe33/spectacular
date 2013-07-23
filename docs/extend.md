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

You can also snakify your own objects using the `utils.snakify` method:

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

The following matchers are provided by Spectacular:

<table cellspacing="0">

  <tr>
    <td>`exist`</td>
    <td>Test if the actual value is neither `null` nor `undefined`.</td>
  </tr>
  <tr>
    <td>`equal(value)`</td>
    <td>Performs a comparison between the actual value and the provided one, objects and arrays are compared by their content and not by their identity. Strings, objects and arrays comparison also includes a diff between the two elements in the matcher message.</td>
  </tr>
    <td>`be(value)`</td>
    <td>The `be` matcher have different behavior according to the type of the provided value.
      <ul>
        <li>If a string is passed, the matcher will look for a property named either `value`, `isValue` or `is_value`, if the property contained a function it will call it, in the end if the value is `true` the match succeed. It is useful to test the state of an object. For instance you can test the resolution of a promise with `@promise.should be 'fulfilled'`
        </li>
        <li>If the value is an object or an array, the identity of the object is tested using the `===` operator.</li>
        <li>Boolean and numeric values are test by value like with the `equal` matcher.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>`beWithin(delta).of(value)`</td>
    <td>The `beWithin` matcher checks that the actual is within a delta of your expected value. This is helpful when normal equality expectations do not work well for floating point values.
      <ul><li>`pi.should beWithin(0.1).of(3.14)`</li></ul>
    </td>
  </tr>
  <tr>
    <td>`have(count, property)`</td>
    <td>The `have` matcher will behave differently according the type of the actual value:
    <ul>
      <li>If the value is a string, the matcher will test for the length of the string, the `property` argument will then be used as a description but can be omitted.</li>
      <li>If the value is an array, the matcher will test the length of the array, the `property` argument will then be used as a description but can be omitted.</li>
      <li>If the value is an object, the matcher will test the length of an array stored in the `property` property of this object. In that case `property` is mandatory.</li>
      <li>For any other type the matcher will fail.</li>
    </ul>
    </td>
  </tr>
  <tr>
    <td>`haveSelector(selector)`</td>
    <td>Will test a `Node` or a `NodeList` with the given CSS query.</td>
  </tr>
  <tr>
    <td>`match(expression)`</td>
    <td>Will either test a regexp against a string or a DOM expression against a node or a node list.
      <ul>
        <li>`'string'.should match /string/`</li>
        <li>`node.should match @domExpression`</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>`contains(element)`</td>
    <td>Will either test the presence of `element` in an array or a dom expression in a node or a node list.</td>
  <tr>
    <td>`throwAnError(message)`</td>
    <td>
      When the subject is a function it will test that the function throw an error. The `message` argument will be used to test the error message. If no message is passed only the throw of an error is tested.

      The `throwAnError` matcher provides additional methods to specify the arguments and context of the call:
      <ul>
        <li>`throwAnError(message).with(arguments...)`: Sets the arguments to use for the call and return the matcher.</li>
        <li>`throwAnError(message).inContext(context)`: Sets the context of the call and return the matcher.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>`haveBeenCalled`</td>
    <td>
      When the subject is a spy it will test for previous calls on this spy.

      The arguments passed to the spy can be tested with the following syntax:
      <ul><li>`haveBeenCalled.with(arguments...)`:</li></ul>
    </td>
  </tr>
</table>

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
