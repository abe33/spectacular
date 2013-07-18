---
title: Tests Tools
date: 2013-07-17 20:26
author: Cédric Néhémie <cedric.nehemie@gmail.com>
template: page.jade
----

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
# {id: 12345, name: 'John Doe', bike: {model: 'z750', brand: 'Kawasaki'}}
```

Factories can be reopened any time to add traits or new configuration:

```coffeescript
factory 'user', ->
  set 'age', 32

user = create 'user'
# {id: 12345, name: 'John Doe', age: 32}
```

Factories can also extends another factory with the `extends` option:

```coffeescript
factory 'admin', extends: 'user', ->
  set 'roles', -> ['admin']

user = create 'admin'
# {id: 12345, name: 'John Doe', roles: ['admin']}
```

### Factory Mixins

Factories, as classes, can includes mixins. In that context a mixin is a function executed on a given factory to defines traits and property for this factory.

```coffeescript
factoryMixin 'has parent', (factory) ->
  set 'parent', null

  trait 'with parent', ->
    set 'parent', -> create factory.name

factory 'category', class: Object, ->
  include 'has parent'

  set 'name', -> Faker.Lorem.sentence()

category = create 'category', 'with parent'
# {
#   name: 'Ut consectetur sed nihil vel dolores qui qui assumenda.'
#   parent: {
#     name: 'Sunt vitae maiores sit.'
#   }
# }
```

### Factory Hooks

Using the `after` method you can  set a block to be executed after the object was instanciated and all traits have been applied:

```coffeescript
factory 'object', class: Object, ->
  set 'field', 'value'

  after 'build', (object) ->
    object.propertiesCount = Object.keys(object).length
```

Currently `build` is the only hook available on a factory.

### Customize Factory Builds

If you're not happy with the way Spectacular instanciate objects, or that what you're building can't be instanciated through the `new` operator, you can override the factory build process using the `build` function.

For instance, given that we have models that may be created through a `create` method, wa can construct a factory as such:

```coffeescript
factory 'my_model', class: MyModel, ->
  build (cls, args) -> cls.create.apply cls, args

  # ...
```

In that case the create method will use the provided build block instead of
the global `spectacular.factories.build` method.

Build blocks are inherited from a parent factory and can be overriden in traits or in child factories.

### Factory Functions

Find below more details about the factory functions:

<table cellspacing="0">
  <tr>
    <td>`factory`</td>
    <td>The `factory` method registers a factory, it takes an option object that set the constructor function to use.</td>
  </tr>
  <tr>
    <td>`factoryMixin`</td>
    <td>The `factoryMixin` method registers a factory mixin, it takes the mixin name and a block to execute when included in a factory.</td>
  </tr>
  <tr>
    <td>`createWith`</td>
    <td>The `createWith` method defines the arguments to pass to the constructor. It can be either a list of values or a function that will return these arguments. In the case a function is passed, the function will be executed in the context of the current example. The `createWith` method can be used either in the factory block or in a trait block. When using several trait defining constructor arguments only the last trait will be effective.</td>
  </tr>
  <tr>
    <td>`set`</td>
    <td>The `set` method defines a value to set on the specified property, it can takes either a value or a function. In case of a function is passed, the function will be executed in the context of the instance.</td>
  </tr>
  <tr>
    <td>`trait`</td>
    <td>The `trait` method registers a trait for this factory. A trait can redefines the arguments to pass to the constructor.</td>
  <tr>
    <td>`build`</td>
    <td>The `build` method allow to redefine the build function for this factory.</td>
  </tr>

  <tr>
    <td>`after`</td>
    <td>The `after` method takes the name of a hook and a block to execute during that hook. Currently only the </td>
  </tr>

  <tr>
    <td>`include`</td>
    <td>The `include` method takes one or more string containing mixins's names.</td>
  </tr>
</table>

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

These expressions, when parsed, can be passed to the `match` or `contains` matchers and can be used with both nodes and nodes lists.

```coffeescript
specify 'the page', ->
  document.should contains @domExpression

specify 'the node', ->
  # on node
  document.querySelector('div').should match @domExpression

  # on nodes list
  document.querySelectorAll('div').should match @domExpression
```

## Shared Example

Shared example are groups of tests that can be used to test similar functionalities accross several classes. For instance the following shared examples test that an object behave like a collection as defined by the `spectacular.HasCollection` mixin:

```coffeescript
sharedExample 'a collection', (options) ->
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

    context 'removing an inexistent item', ->
      before -> @subject["remove#{capitalizedSingular}"] @item2

      specify 'the collection', ->
        @subject[plural].should contains @item
```

The shared example can then be called with either the `itBehavesLike` or `itShould` functions:

```coffeescript
describe ClassWithCollection, ->
  subject -> new ClassWithCollection

  itBehavesLike 'a collection', {
    singular: 'child'
    plural: 'children'
  }
```

## Tests Helpers

Helpers can be created and exposed with the `spectacular.helper` function.
The function takes a name and a value and will expose it on the global object
through a `GlobalizableObject`.

```coffeescript
spectacular.helper 'someHelper', (params...) ->
  # Your helper's code

# Usage
someHelper(SomeClass, someOption: 'some value')
```
