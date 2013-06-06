---
title: Introduction
date: 2013-06-05 20:19
author: Cédric Néhémie <cedric.nehemie@gmail.com>
template: page.jade
----

Spectacular is a <abbr title='Behavior-Driven Development'>BDD</abbr> framework for CoffeeScript and JavaScript whose attempt to bring the power of RSpec to JavaScript. Spectacular try to favor the best practices used for writing [better RSpec tests](http://betterspecs.org/) in its design.

```coffeescript
describe Array, ->
  it -> should exist

  itsInstance 'length', -> should equal 0

  describe '::indexOf', ->
    itsReturn with: ['foo'], -> should equal -1
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
