---
title: Introduction
date: 2013-06-05 20:19
author: Cédric Néhémie <cedric.nehemie@gmail.com>
template: page.jade
----
[![Build Status](https://travis-ci.org/abe33/spectacular.png)](https://travis-ci.org/abe33/spectacular)
[![Coverage Status](https://coveralls.io/repos/abe33/spectacular/badge.png?branch=master)](https://coveralls.io/r/abe33/spectacular?branch=master)
[![Dependency Status](https://gemnasium.com/abe33/spectacular.png)](https://gemnasium.com/abe33/spectacular)
[![NPM version](https://badge.fury.io/js/spectacular.png)](http://badge.fury.io/js/spectacular)

Spectacular is a <abbr title='Behavior-Driven Development'>BDD</abbr> framework for CoffeeScript and JavaScript whose attempt to bring the power of RSpec to JavaScript. Spectacular try to favor the best practices used for writing [better RSpec tests](http://betterspecs.org/) in its design.

This is the kind of tests you can write with Spectacular:

```coffeescript
describe Array, ->
  given 'item', -> foo: 'bar'

  it -> should exist

  itsInstance 'length', -> should equal 0

  describe '::indexOf', ->
    context 'with an item not present in the array', ->
      itsReturn with: (-> [@item]), -> should equal -1

    context 'with an item present in the array', ->
      subject 'array', -> [@item]

      specify 'the returned value', ->
        expect(@array.indexOf @item).to equal 0
```

### Features, the short tour

  * Conditionned Specs
  * Matcher based description
  * Implicit subjects
  * Describe auto-subject
  * Factories
  * JSON and HTML fixtures (and more)
  * Promised-based tests run
  * Synchronous and asynchronous matchers
  * Synchronous and asynchronous tests
  * Browser support
  * Shared examples
  * Custom matchers
  * CSS-queries expressions to test the DOM content
  * Strings and objects diff in comparison results
  * The API is provided with both camelCase and snake_case version
  * No external dependencies in browsers

## Install

Spectacular is available as a [npm](http://npmjs.org) module, you can then install it with:

```shell
npm install -g spectacular
```

This will install Spectacular globally and allow you to use the Spectacular command line tool.

## Command-line

The most simple way to use the spectacular command line tool is as follow:

```shell
spectacular specs/**/*.spec.js
```

### Options

<table cellspacing="0">
  <tr>
    <td>`-c, --coffee`</td>
    <td>Add support for CoffeeScript files. You can now run your specs with: `spectacular --coffee specs/**/*.coffee`.</td>
  </tr>
  <tr>
    <td>`-v, --verbose`</td>
    <td>Enable verbose output.</td>
  </tr>
  <tr>
    <td>`-t, --trace`</td>
    <td>Enable stack trace report for failures (default is `true`).</td>
  </tr>
  <tr>
    <td>`--long-trace`</td>
    <td>By default the stack traces are cropped after 6 lines to limit the amount of output. You can display the full stack trace with this option.</td>
  </tr>
  <tr>
    <td>`-p, --profile`</td>
    <td>Add a report with the 10 slowest examples at the end of the output.</td>
  </tr>
  <tr>
    <td>`-d, --documentation`</td>
    <td>Enable the documentation format in the output.</td>
  </tr>
  <tr>
    <td>`-s, --server`</td>
    <td>Starts a server instead of running the specs. The specs can then be accessed from a browser at the the following address: `http://localhost:5000`.</td>
  </tr>
  <tr>
    <td>`-m, --matchers PATH`</td>
    <td>Specify the path where project matchers can be found, by default matchers are loaded from `./specs/support/matchers`.</td>
  </tr>
  <tr>
    <td>`--helpers PATH`</td>
    <td>Specify the path where project helpers can be found, by default helpers are loaded from `./specs/support/helpers`.</td>
  </tr>
  <tr>
    <td>`--fixtures PATH`</td>
    <td>Specify the path where project fixtures can be found, by default fixtures are loaded from `./specs/support/fixtures`.</td>
  </tr>
  <tr>
    <td>`--no-trace`</td>
    <td>Remove stack trace from failures reports.</td>
  </tr>
  <tr>
    <td>`--no-colors`</td>
    <td>Remove coloring from the output.</td>
  </tr>
  <tr>
    <td>`--no-matchers`</td>
    <td>Disable the loading of project matchers.</td>
  </tr>
  <tr>
    <td>`--no-helpers`</td>
    <td>Disable the loading of project helpers.</td>
  </tr>
</table>

## Examples and ExampleGroups

`ExampleGroups` are created with either the `describe` or `context` methods, new aliases can be created with `spectacular.env.createExampleGroupAlias(newName)`.

`Examples` are created with `it`, `the` or `specify`, and new aliases can be created with `spectacular.env.createExampleAlias(newName)`.

```coffeescript
describe 'a group', ->
  context 'a child group', ->
    specify 'an example', ->
      [0,1,2].should contains 1
```

### Pending Examples

Examples that doesn't have a block, or that have a block that doesn't contains any assertions are considered as `pending`.

You can force an example to be marked as pending by either calling the pending method in its block or using the `xit` method.

```coffeescript
it 'is pending'

it 'is pending', ->

it 'is pending', -> pending()

xit 'is pending', -> [1,2,3].should contains 1
```

Example groups without block are also considered as pending.
It's also possible to use either `xdescribe` or `xcontext` to mark a group as
pending.

```coffeescript
describe 'a pending group'

xdescribe 'a pending group', ->
  # ...

xcontext 'a pending context', ->
  # ...
```

### Asynchronous Examples

To create an asynchronous example, just specify an argument to the example
block. A pending promise will be passed to the block. The example can then
either `resolve` or `reject` the promise.

```coffeescript
specify 'an asynchronous example', (async) ->
  doSomethingAsync (err, res) ->
    return async.reject err if err?

    res.should exist
    async.resolve()
```

In the case the promise is rejected the passed-in reason will be used as failure message.

By default asynchronous example have a timeout limit of 5000ms, but it can be changed using the `rejectAfter` method of the promise.

```coffeescript
specify 'a heavy asynchronous example', (async) ->
  async.rejectAfter 60000, 'timeout message'

  # ...
```

### Conditionned Examples

Examples can depends on other examples. If all their dependency succeed the example is run, otherwise the example is marked as `skipped`.

There's two type of dependencies, an example can either depends on examples from another context:

```coffeescript
describe 'first context', id: 'contextId', ->
  # ...

describe 'depending context', ->
  dependsOn 'contextId'

  # ...
```
In that case, the `depending context`'s example will only be run when all the examples in `first context` succeed.

The other type of dependencies is called cascading dependency, examples in a sub-context will only if the examples in its parent context have all succeed.

```coffeescript
describe 'parent context', ->
  specify 'a parent example', ->
    # ...

  whenPass ->
    specify 'a child example', ->
      # ...
```
In that case, the child example will only run if the parent example succeed.

### Examples Subject

As in RSpecs, example groups can define a subject that will be available in all their examples:

```coffeescript
describe 'a subject', ->
  subject -> {}

  it -> should exist
```

Some methods such `its`, `itsReturn` and `itsInstance` will test some aspect of a previous subject:

  * `its 'property'` will use the content of the specified property as subject for the test block.
  * `itsReturn` when the current subject is a function will use the value returned by the function as the subject for the test block. It accept two options `with` and `inContext` to set respectively the arguments of the call and the call context.
  * `itsInstance` when the current subject is a function will create an instance and use it as the subject for the test block. It accept a `with` options to defines the arguments to pass to the constructor.
  * `itsInstance 'property'` when the current subject is a function will create an instance and use the value of the specified property as the subject for the test block.

### Auto-subjects

The `describe` function can be used to specify an implicit subject for test.

```coffeescript
describe AClass, ->
  withArguments a, b, c

  # subject here is the class constructor function
  it -> should exist

  # Automatically create an instance with
  # the provided parameters as subject
  itsInstance -> should exist

  # The subject is now AClass.someClassMethod
  describe '.someClassMethod', ->
    context 'called with some parameters', ->
      # subject is now the result
      # of calling AClass.someMethod(10)
      itsReturn with: [10], -> should equal 20

  describe '::someInstanceMethod', ->
    context 'called with some parameters', ->
      # subject is now the result
      # of calling new Aclass(a,b,c).someInstanceMethod('foo')
      itsReturn with: ['foo'], -> should equal 'oof'
```

## Assertions

Spectacular support two types of assertions, either with the `should` function or with the `èxpect(...).to` syntax. As addition, the `Object`'s prototype is decorated with a `should` method, allowing to write `10.should equal 10`.


The global `should` function will use the current example subject as actual value to pass to the provided matcher.

```coffeescript
describe 'a number', ->
  subject -> 10

  it -> should equal 10

  it -> @subject.should equal 10

  it -> expect(@subject).to equal 10
```
The matchers's description is used as part of the examples description, for instance the following example:

```coffeescript
specify 'the value', -> should equal 10
```

Will produce a description such as:

```
the value should be equal to 10
```

The `expect` function will use the passed-in value as well in the description:

```coffeescript
specify 'the value', -> expect(10).to equal 10
```

Gives:

```
the value 10 should be equal to 10
```

The inverse of `should` is `shouldnt`.
The inverse of `expect(...).to` is `expect(...).not.to`.

### Matchers

Matchers are defined with the `spectacular.matcher` function. It generates an object with a `match` method that should return a boolean value corresponding to the assertion result.

```coffeescript
spectacular.matcher 'returnSomething', ->
  match (actual, notText) ->
    @description = "should#{notText} return something"
    @message = "Expected #{actual} to return something"

    actual() isnt null

# Usage:
it -> should returnSomething
```

The matcher receive a string containing `' not'` if the matcher was passed to `shouldnt` or `expect(...).not.to`.

If an exception is raised during the matcher execution, the example will be marked as `errored` instead of `failure`.

You can create parameterizable matcher by calling the `takes` function in the matcher definition block.

```coffeescript
spectacular.matcher 'parameterizableMatcher', ->
  takes 'value1', 'value2'
  match ->
    @description = 'parameterizableMatcher description'
    @message = 'parameterizableMatcher message'

    @value1 and @value2

# Usage:
it -> should parameterizableMatcher(true, true)
```

The parameters defined with takes are then stored in the matcher instance with the provided names.

The following matchers are provided by Spectacular:

<table>

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
        <li>If a string is passed, the matcher will look for a property named either `value`, `isValue` or `is_value`, if the property contained a function it will call it, in the end if the value is `true` the match succeed. It is usefull to test the state of an object. For instance you can test the resolution of a promise with `@promise.should be 'fulfilled'`
        </li>
        <li>If the value is an object or an array, the identity of the object is tested using the `===` operator.</li>
        <li>Boolean and numeric values are test by value like with the `equal` matcher.</li>
      </ul>
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
    <td>`have.selector(selector)`</td>
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

### Asynchronous Matchers

Matchers can be asynchronous, in that case they should return a promise instead of a boolean value. The default timeout for asynchronous matchers is 5000ms, it can be changed by setting the `timeout` in the matcher block.

```coffeescript
spectacular.matcher 'asyncMatcher', ->
  timeout 1000
  match (actual, notText) ->
    @description = 'should match asynchronously'
    @message = 'Expected to match asynchronously'

    promise = new spectacular.Promise

    setTimeout (-> promise.resolve actual isnt null), 100

    promise
```
If the promise is rejected, the example is marked as `errored`.

## Tests Helpers

Helpers can be created and exposed with the `spectacular.helper` function.
The function takes a name and a value and will expose it on the global object
through a `GlobalizableObject`.

```coffeescript
spectacular.helper 'environmentMethod', (method) ->
  cannotBeCalledInsideIt: ->
    runningSpecs('call inside it')
    .shouldFailWith /called inside a it block/, ->
      describe 'foo', ->
        it -> spectacular.global[method]()
```

## Before & After Hooks

Before and after hooks are defined in a per context basis.

```coffeescript
describe 'context with hooks', ->
  before -> fs.writeFileSync 'path', 'content'
  after -> fs.unlink 'path'

  specify 'an example', ->
    fs.readFileSync('path').should exist
```

Hooks can be asynchronous in the same way as example:

```coffeescript
describe 'context with hooks', ->
  before (async) -> fs.writeFile 'path', 'content', (err) ->
    return async.reject err if err?
    async.resolve()

  after (async) ->
    fs.unlink 'path'
    async.resolve()

  specify 'an example', (async) ->
    fs.readFile 'path', (err, content) ->
      return async.reject err if err?

      content.should exist
      async.resolve()
```

The same rules apply for hooks than for examples, meaning that a rejected promise end with the example marked as `errored`, and the timeout can be changed using the `rejectAfter` method of the promise.

## Spies & Mocks

Spies and mocks can be created in the same way as in Jasmine:

```coffeescript
before ->
  # Intercepts the returned value of the spied method call and passed
  # it to the provided method
  spy = spyOn(object, 'method').andCallThrough (result) -> result

  # Mock the call to the method with another one.
  spy = spyOn(object, 'method').andCallFake ->

  # Mock the call to the method by returning the given value
  spy = spyOn(object, 'method').andReturns(value)
```

## Factories

Spectacular provides native factories in a FactoryGirl manner:

```coffeescript
class User
  constructor: (@id) ->

factory 'user', class: User, ->
  createWith -> Math.floor Math.random() * 100000

  set 'name', -> 'John Doe'

  trait 'with_bike', ->
    set 'bike', -> {model: 'z750', brand: 'Kawasaki'}

user = create 'user', 'with_bike'
```

  * The `factory` method registers a factory, it takes an option object that set the constructor function to use.
  * The `createWith` method defines the arguments to pass to the constructor. It can be either a list of values or a function that will return these arguments. In the case a function is passed, the function will be executed in the context of the current example.
  * The `set` method defines a value to set on the specified property, it can takes either a value or a function. In case of a function is passed, the function will be executed in the context of the instance.
  * The `trait` method registers a trait for this factory. A trait can redefines the arguments to pass to the constructor.

## Fixtures

Fixtures are files that will be loaded before a test execution. Fixture files
can be processed before being stored in the context if its extension matches
one of the processor defined in the environment.

```coffeescript
describe 'with a fixture', ->
  # will be loaded, parsed and stored in @fixture
  fixture 'sample.json'

  # will be loaded, injected in a DOM (either jsdom on node
  # or in a #fixtures div in a browser) and stored in @html
  fixture 'sample.html', as: 'html'

  # will be loaded, parsed to create a DOMExpression
  # and stored in @dom
  fixture 'sample.dom', as: 'dom'

  #...
```
In practice, a fixture is a before block that load the file, pass it to a processor (if any) and stored in a property in the context.

## DOM Expression

Spectacular provides a tool to perform deep test over a DOM structure called `DOMExpression`, it can be created either using fixtures with the `.dom` extensions or using the `spectacular.dom.DOMExpression` class.

A DOM expression is basically a tree of css query strings that describe an HTML structure. For instance a typical webpage can be represented with:

```
html
  head
  body
```

DOM expressions use the `querySelectorAll` method to perform this test. First it will look for the `html` query and then perform the `head` and `body` queries on the results.

It's also possible to test the text content of a node using quote or regex literal in the expression.

```
#section
  article
    h3
      'article title'
    p
      /article(\s+content)*/
```

These expressions, when parsed, can be passed to the `match` or `contains` matchers.

```coffeescript
specify 'the page', ->
  document.should contains @domExpression

specify 'the node', ->
  node.should match @domExpression
```

## Shared Example

Shared example are groups of tests that can be used to test similar functionalities accross several classes. For instance the following shared examples test that an object behave like a collection as defined by the `spectacular.HasCollection` mixin:

```coffeescript
sharedExample 'a collection like object', (options) ->
  {singular, plural} = options
  capitalizedSingular = spectacular.utils.capitalize singular

  context 'adding an item', ->
    given 'item', -> {}
    given 'item2', -> {}

    before -> @subject["add#{capitalizedSingular}"] @item

    specify 'the collection', ->
      @subject[plural].should contains @item

    specify "then calling has#{capitalizedSingular}", ->
      @subject["has#{capitalizedSingular}"](@item).should be true

    specify 'the item index', ->
      @subject["find#{capitalizedSingular}"](@item).should equal 0

    specify 'the item at index 0', ->
      @subject["#{singular}At"](0).should be @item

    context 'then removing it', ->
      before -> @subject["remove#{capitalizedSingular}"] @item

      specify 'the collection', ->
        @subject[plural].shouldnt contains @item

    context 'removing an inexistant item', ->
      before -> @subject["remove#{capitalizedSingular}"] @item2

      specify 'the collection', ->
        @subject[plural].should contains @item
```

The shared example can then be called with either the `itBehavesLike` or `itShould` functions:

```coffeescript
describe ClassWithCollection, ->
  subject -> new ClassWithCollection

  itBehavesLike 'a collection like object', {
    singular: 'child'
    plural: 'children'
  }
```

## Snake Case Syntax

All the exposed methods are provided both with `camelCase` and `snake_case` syntax. By convention, JavaScript use the camel case form, but some people writing CoffeeScript for nodejs often use the snake case form. Spectacular support both.

You can define any matcher, or helper, or aliases, with either the snake case
or camel case form, the alternative will be also added to the globale object.

For instance, the `sharedExample` is also available through `shared_example`.

You can find below a table with all the snake case equivalent:

<table>
    <tr><td>`after`</td><td>No differences</td></tr>
    <tr><td>`before`</td><td>No differences</td></tr>
    <tr><td>`contains`</td><td>No differences</td></tr>
    <tr><td>`context`</td><td>No differences</td></tr>
    <tr><td>`createWith`</td><td>`create_with`</td></tr>
    <tr><td>`dependsOn`</td><td>`depends_on`</td></tr>
    <tr><td>`describe`</td><td>No differences</td></tr>
    <tr><td>`equal`</td><td>No differences</td></tr>
    <tr><td>`exist`</td><td>No differences</td></tr>
    <tr><td>`expect`</td><td>No differences</td></tr>
    <tr><td>`factory`</td><td>No differences</td></tr>
    <tr><td>`fail`</td><td>No differences</td></tr>
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
