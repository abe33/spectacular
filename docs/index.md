---
title: Introduction
date: 2013-06-05 20:19
author: Cédric Néhémie <cedric.nehemie@gmail.com>
template: page.jade
----

Spectacular is a <abbr title='Behavior-Driven Development'>BDD</abbr> framework for CoffeeScript and JavaScript whose attempt to bring the power of RSpec to JavaScript. Spectacular tries to favor the best practices used for writing [better RSpec tests](http://betterspecs.org/) in its design.

These are the kind of tests you can write with Spectacular:

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

## Features, the short tour

  * Conditioned Specs
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

----

## Install


### NodeJS

Spectacular is available as a [npm](http://npmjs.org) module, you can then install it with:

```shell
npm install -g spectacular
```

This will install Spectacular globally and allow you to use the Spectacular command line tool.

### Browser

First download Spectacular:

<div id="download"><a href='spectacular-1.5.1.zip' class='download' target='_blank'><i class='icon-download'></i>Download</a></div>

Then puts Spectacular in your html file:

```xml
<link href="build/css/spectacular.css" rel="stylesheet" type="text/css"/>
<script src="build/vendor/snap.js" type="text/javascript"/>
<script src="build/vendor/jade.js" type="text/javascript"/>
<script src="build/js/spectacular.js" type="text/javascript"/>
<script src="build/js/templates.js" type="text/javascript"/>
```

You can see the runner live on the [Online Test Tool](./tests.html) page.

You can pass options to spectacular by defining `spectacular.options` before the spectacular script node :

```coffeescript
spectacular =
  options:
    verbose: false
    trace: true
    longTrace: false
    showSource: true
    fixturesRoot: './js/fixtures'
    globs: []
```

You can also pass an array containing the paths to the specs files in a `spectacular.paths` array.

```coffeescript
spectacular =
  paths: ['js/specs.js']
```

It will allow the runner to crop the stack at the point a spec file is found and display the source of the test that failed. Errored test's stack is not cropped.

#### Spectacular Server

If you don't want to bother create a html file to run your test you can use the server feature of Spectacular.

By running:

```bash
spectacular server specs/**/*.spec.coffee
```

You start a server that can be accessed on `http://localhost:5000`. It bootstrap Spectacular for you with your tests, helpers, matchers, etc.

The same server is used to run tests on [PhantomJS](http://phantomjs.org/) and [SlimerJS](http://slimerjs.org/).

#### Source Map Support

If you use the Spectacular server to test your code on the browser, no additional configuration is needed. However, if you use Spectacular in your own test page some additional configuration is needed to enable source mapping.

In order for Spectacular to kown which files have source mapping and how to retrieve the source and the mapping for that file, some methods have to be defined in the options before the Spectacular start:

  * `hasSourceMap`: A function that takes an url and return true if the file have source map support.
  * `getSourceURLFor`: A function that takes an url and return the url of the corresponding source file.
  * `getSourceMapURLFor`: A function that takes an url and return the url of the json containing the source mapping.

A concrete example can be seen in the Spectacular server's source :

```javascript
spectacular.options.hasSourceMap = function(file) {
  return /\.coffee$/.test(file);
};
spectacular.options.getSourceURLFor = function(file) {
  return file.replace('.coffee', '.coffee.src')
};
spectacular.options.getSourceMapURLFor = function(file) {
  return file.replace('.coffee', '.map')
};
```

#### Browser Support

Spectacular rely on some feature that may not be available in all browsers. You can find below the list of features and the minimum browser version needed to use them.

<div class="caniuse_static">
  <h1>Object.defineProperty</h1>
  <p class="status">ECMAScript 5</p>
  <p>Supported from the following versions:</p>
  <h2 id="Desktop">Desktop</h2>
  <ul class="agents">
    <li title="Chrome - Yes" class="icon-chrome y"><span class="version">5</span></li>
    <li title="Firefox - Yes" class="icon-firefox y"><span class="version">4</span></li>
    <li title="IE - Yes" class="icon-ie y"><span class="version">9</span></li>
    <li title="Opera - Yes" class="icon-opera y"><span class="version">11.60</span></li>
    <li title="Safari - Yes" class="icon-safari y"><span class="version">5.1</span></li>
  </ul>
  <h2 id="Mobile-Tablet">Mobile / Tablet</h2>
  <ul class="agents">
    <li title="iOS Safari - Yes" class="icon-ios_saf y"><span class="version">0</span></li>
    <li title="Android Browser - Yes" class="icon-android y"><span class="version">0</span></li>
    <li title="Opera Mobile - Yes" class="icon-op_mob y"><span class="version">11.50</span></li>
    <li title="Chrome for Android - Yes" class="icon-and_chr y"><span class="version">0</span></li>
    <li title="Firefox for Android - Yes" class="icon-and_ff y"><span class="version">4</span></li>
  </ul>
  <ul class="legend">
    <li>Supported:</li>
    <li class="y">Yes</li>
    <li class="n">No</li>
    <li class="a">Partially</li>
    <li class="p">Polyfill</li>
  </ul>
  <p class="stats">Stats from <a href="http://mdn.beonex.com/en/JavaScript/Reference/Global_Objects/Object/defineProperties.html" target="_blank">mdn</a></p>
</div>
<div class="caniuse" data-feature="querySelector"></div>

## Command-line

The most simple way to use the spectacular command line tool is as follow:

```shell
spectacular test specs/**/*.spec.js
```
### Commands

<table cellspacing="0">
  <tr>
    <td>`test`</td>
    <td>Runs the tests on NodeJS.</td>
  </tr>

  <tr>
    <td>`server`</td>
    <td>Starts a server. The specs can then be accessed from a browser at the the following address: `http://localhost:5000`. The default port can be changed by setting the `PORT` environment variable.</td>
  </tr>

  <tr>
    <td>`phantomjs`</td>
    <td>Assuming you have PhantomJS installed, it starts a server and run the test on PhantomJS.</td>
  </tr>

  <tr>
    <td>`slimerjs`</td>
    <td>Assuming you have SlimerJS installed, it starts a server and run the test on SlimerJS.</td>
  </tr>
</table>

### Options

<table cellspacing="0">
  <tr>
    <td>`-c, --coffee`</td>
    <td>Add support for CoffeeScript files. You can now run your specs with: `spectacular --coffee specs/**/*.coffee`.</td>
  </tr>
  <tr>
    <td>`-f, --format`</td>
    <td>Select the console output format (progress|documentation).</td>
  </tr>
  <tr>
    <td>`-r, --require PATH`</td>
    <td>Adds `PATH` to the array of paths to includes.</td>
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
    <td class="deprecated">`-d, --documentation`</td>
    <td>Use `--format=documentation` option instead.</td>
  </tr>
  <tr class='deprecated'>
    <td>`-s, --server`</td>
    <td>Use the `server` command instead.</td>
  </tr>
  <tr class='deprecated'>
    <td>`--phantomjs`</td>
    <td>Use the `phantomjs` command instead.</td>
  </tr>
  <tr>
    <td>`--phantomjs-bin PATH`</td>
    <td>Pass the path to the PhantomJS binary.</td>
  </tr>
  <tr>
    <td>`--slimerjs-bin PATH`</td>
    <td>Pass the path to the SlimerJS binary.</td>
  </tr>
  <tr>
    <td>`--source GLOB`</td>
    <td>When using the server, it allow to add files that matches the patterns as served files in the html runner. You can use this option as many times as you need.</td>
  </tr>
  <tr>
    <td>`--map, --source-map`</td>
    <td>Enable the support for CoffeeScript source map on both node and browsers. When using this mode with the browser without relying on the Spectacular server additional setup is required, please see the [Source Map Support](#Source-Map-Support) section for details.</td>
  </tr>
  <tr>
    <td class='deprecated'>`-m, --matchers PATH`</td>
    <td>Use `--require PATH` instead.</td>
  </tr>
  <tr>
    <td class="deprecated">`--helpers PATH`</td>
    <td>Use `--require PATH` instead.</td>
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
    <td>`--random`</td>
    <td>Enable tests randomization.</td>
  </tr>
  <tr>
    <td>`--no-random`</td>
    <td>Disable tests randomization.</td>
  </tr>
  <tr>
    <td>`--seed INT`</td>
    <td>Sets the seed for the tests randomization.</td>
  </tr>
  <tr>
    <td>`--colors`</td>
    <td>Enable coloring of the output.</td>
  </tr>
  <tr>
    <td>`--no-colors`</td>
    <td>Disable coloring of the output.</td>
  </tr>
  <tr>
    <td class="deprecated">`--no-matchers`</td>
    <td>Don't require your matchers instead.</td>
  </tr>
  <tr>
    <td class="deprecated">`--no-helpers`</td>
    <td>Don't require your helpers instead.</td>
  </tr>
</table>

Options can also be defined in a `.spectacular` file at the root of your project.
