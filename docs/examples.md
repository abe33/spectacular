---
title: Writing Specs
date: 2013-07-17 20:26
author: Cédric Néhémie <cedric.nehemie@gmail.com>
template: page.jade
----

## Examples and ExampleGroups

`ExampleGroups` are created with either the `describe` or `context` methods, new aliases can be created with `spectacular.env.createExampleGroupAlias(newName)`.

`Examples` are created with `it`, `the` or `specify`, and new aliases can be created with `spectacular.env.createExampleAlias(newName)`.

```coffeescript
describe 'a group', ->
  context 'a child group', ->
    specify 'an example', ->
      [0,1,2].should contains 1
```

## Pending Examples

Examples that doesn't have a block, or that have a block that doesn't contains any assertions are considered as `pending`.

You can force an example to be marked as pending by either calling the pending method in its block or using the `xit` method.

```coffeescript
it 'is pending'

it 'is pending', ->

it 'is pending', -> pending()

xit 'is pending', -> [1,2,3].should contains 1
```

Example groups without block or without examples are also considered as pending. It's also possible to use either `xdescribe` or `xcontext` to mark a group as pending.

```coffeescript
describe 'a pending group'

describe 'a pending group', ->

xdescribe 'a pending group', ->
  # ...

xcontext 'a pending context', ->
  # ...
```

## Asynchronous Examples

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

## Conditioned Examples

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

## Auto-subjects

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

Instance members can also be accessed with a `#` instead of `::`.

# Assertions

Spectacular support two types of assertions, either with the `should` function or with the `expect(...).to` syntax. As addition, the `Object`'s prototype is decorated with a `should` method, allowing to write `10.should equal 10`.


The global `should` function will use the current example subject as actual value to pass to the provided matcher.

```coffeescript
describe 'a number', ->
  subject -> 10

  it -> should equal 10

  it -> @subject.should equal 10

  it -> expect(@subject).to equal 10
```
The matcher's description is used as part of the examples description, for instance the following example:

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
