<a name="1.5.0"></a>
# 1.5.0 (2013-11-24)


## Bug Fixes

- **$travis:**
  - fix slimerjs download on travis
  ([2bfd58f0](https://github.com/abe33/spectacular/commit/2bfd58f0def471bfa6086c20021392d3ad3c4b25))
  - fix broken phantomjs run
  ([eabb7965](https://github.com/abe33/spectacular/commit/eabb7965da9c77c25c3100239a0059aac1635fa2))
  - fix error in travis phantomjs with error stack
  ([8fd28569](https://github.com/abe33/spectacular/commit/8fd28569d9802ab9f17d69e059640b56f21c7611))
- **browser:** handle properly server errors response
  ([c63b9908](https://github.com/abe33/spectacular/commit/c63b9908ccd898a3cfbfc9578f30162b2090f489))
- **fixtures:** raise exception early when file doesn't exist
  ([9f69731d](https://github.com/abe33/spectacular/commit/9f69731df0128f91fb284bf7c3101bb91e154079))
- **formatters:** column default should be one for source map
  ([19a72563](https://github.com/abe33/spectacular/commit/19a725637516612495b2b58e0c084d2904c950fe))
- **matchers:** fix match with string behaving like equal
  ([e0e6f751](https://github.com/abe33/spectacular/commit/e0e6f7511f6a358d24a6763d788e0861c1f7303a))
- **pages:**
  - fix dead link to live runner
  ([274e95a0](https://github.com/abe33/spectacular/commit/274e95a0cfdc77dedb69df5ca6e613eddb722805),
   [#13](https://github.com/abe33/spectacular/issues/13))
  - fix error in factory example
  ([b269cd0f](https://github.com/abe33/spectacular/commit/b269cd0ff2e146b4fe1359ae28e4379415419469),
   [#11](https://github.com/abe33/spectacular/issues/11))
- **tests:**
  - fix broken stack crop if no known path is found in stack
  ([f0bd9592](https://github.com/abe33/spectacular/commit/f0bd9592aa60f8903cf3819a4e252beabbd86ca7))
- **utils:** fix broken diff when text contains object extension
  ([7533e0a3](https://github.com/abe33/spectacular/commit/7533e0a367a7daa2a199fa6f9359752912966c8a))


## Features

- **$browser:** add the tests seed in the counters div
  ([b80c61d3](https://github.com/abe33/spectacular/commit/b80c61d3e7a1105faf7b3df9e759834a64616b82))
- **Cakefile:** add templates generation as part of the cake tasks
  ([f0bfc99c](https://github.com/abe33/spectacular/commit/f0bfc99c9c8d8b6b4e40483bff90910e8f5f460c))
- **browser:**
  - add a button in spec details to rerun only this test
  ([3c8e9151](https://github.com/abe33/spectacular/commit/3c8e9151dc87eb40f6cdd0fcb30e3600848cb691))
  - implements an example filter using the filter parameter
  ([1ed5a40a](https://github.com/abe33/spectacular/commit/1ed5a40a69a9838001dee95d82f719c8e211386a))
  - add support for url parameters in browser bootstrap
  ([3150a433](https://github.com/abe33/spectacular/commit/3150a433febc0353556bddeea05ef79a9a9fd7f9))
  - add type parsing in url parameters parser
  ([2f8c9163](https://github.com/abe33/spectacular/commit/2f8c9163ff39896573cb4e87de0ec4dcd5e2808c))
  - add parameters parser first implementation
  ([d4287ecf](https://github.com/abe33/spectacular/commit/d4287ecf5e24466d1b9b0163b582a31882b6a2aa))
  - add a search box in the the list header
  ([9f45e382](https://github.com/abe33/spectacular/commit/9f45e382262715b9002c730bdf24801f34d988ef))
  - prevent errors in tests declarations from running tests
  ([9e8e8f42](https://github.com/abe33/spectacular/commit/9e8e8f42a228c25b907e9048db1188b38ca00731))
  - new mobile friendly UI for browser tests
  ([42f0c7eb](https://github.com/abe33/spectacular/commit/42f0c7eb189f3b123cf7e6635f44fc0c434eadf1))
  - changes browser reporter for a widget based one
  ([cc00840e](https://github.com/abe33/spectacular/commit/cc00840ea5ffec0248ec8611ec721bd553b47793))
- **cli:** add format option to select the prorgess formatter
  ([9b0f8947](https://github.com/abe33/spectacular/commit/9b0f8947f987cc4469f0a1ce049f7e78627ac541))
- **environment:** add fixturePath helper function
  ([5ab77931](https://github.com/abe33/spectacular/commit/5ab779317eb15035a7f7740112f79b4d9c02dbb0))
- **errors:** add extensible error's stack parser
  ([82ffa53e](https://github.com/abe33/spectacular/commit/82ffa53e17df37719957b6776cc977b319895a00))
- **formatters:**
  - add console progress style formatter
  ([2da8cca3](https://github.com/abe33/spectacular/commit/2da8cca3e05014ad9497719afd051355b1ad48bf))
  - add example results formatter
  ([bbd6a233](https://github.com/abe33/spectacular/commit/bbd6a233313e11555a1c23e47080e46f60b7a3fe))
  - add console results formatter
  ([1d8ce45f](https://github.com/abe33/spectacular/commit/1d8ce45fe39c7fcef3d294b762f5deb8243ef361))
  - add console resume formatter
  ([42f6e8e0](https://github.com/abe33/spectacular/commit/42f6e8e068367f291753836dc552e9002696b19d))
  - add console profile formatter
  ([690418af](https://github.com/abe33/spectacular/commit/690418afe4659c6dcf9296dff07ad1c14dbafe10))
  - add console duration formatter
  ([429146b9](https://github.com/abe33/spectacular/commit/429146b9759a39e28152d3c4f15732e201fa9391))
  - add console seed formatter
  ([18431721](https://github.com/abe33/spectacular/commit/184317218bba88a441661ea44b54a15fb4abce63))
  - add errors stack and source file formatters
  ([13d242fc](https://github.com/abe33/spectacular/commit/13d242fc74a9711769e8418270114036434cbb81))
- **matchers:**
  - add haveClass matcher to test node classes
  ([2cea1829](https://github.com/abe33/spectacular/commit/2cea1829df0fe2ef6a5ac005cc2207d89da7a2cd))
  - add haveAttribute and haveAttribtues matchers
  ([8b2d7c00](https://github.com/abe33/spectacular/commit/8b2d7c00d3a16a627189e5ad88fc1f029adeba92))
  - add haveProperty and haveProperties matcher
  ([e1bad8fb](https://github.com/abe33/spectacular/commit/e1bad8fb5188f5891ccfa2d209af1cfc0d2325b7))
  - add support for string in match
  ([1ba8c3e4](https://github.com/abe33/spectacular/commit/1ba8c3e44f98a46d1ca61c84c3f176c4f8f03916))
  - allow value decoration in matchers
  ([9e39fb56](https://github.com/abe33/spectacular/commit/9e39fb56be6fa7a342fb8f5267981f8d337ef9bc))
  - be matcher handle simple constructor type check
  ([dcc42d00](https://github.com/abe33/spectacular/commit/dcc42d0086485f76312bccd5b7c4839205b87031))
- **reporters:** replace old results with formatter based ones
  ([84e46df6](https://github.com/abe33/spectacular/commit/84e46df6cad4ab74de182f4ce465c8f62f11073f))
- **runner:** add a start event after examples registering
  ([91859abe](https://github.com/abe33/spectacular/commit/91859abe2e8ea1c1c08110def66b88bcfc4d8f2a))
- **server:** extract server response content into jade templates
  ([415fb9c1](https://github.com/abe33/spectacular/commit/415fb9c127d232a735fa529f409c7887cda8dfa8))
- **utils:**
  - wrap diffs in a span in browers
  ([5360f6ea](https://github.com/abe33/spectacular/commit/5360f6eacf789cac24888b5a69d8ca46aa61db7e))
  - add colorize method in spectacular.utils
  ([c73ab127](https://github.com/abe33/spectacular/commit/c73ab1270c90c97fbe6680b1e2acf822161b0e1a))
- **widgets:** add pluralizationof states in progress widget
  ([4a3017d2](https://github.com/abe33/spectacular/commit/4a3017d224ac8f38a6617f1c8ec843509d1d552b))


<a name="1.4.0"></a>
# 1.4.0 (2013-08-25)


## Bug Fixes

- **$support:** fix broken test on Opera 12
  ([3911ecd8](https://github.com/abe33/spectacular/commit/3911ecd8e88c7b5b4a22d6e2fad7a308bc034aef))
- **headless:** fix some bugs occuring in phantomjs and slimerjs on travis
  ([c3573df7](https://github.com/abe33/spectacular/commit/c3573df72f53778ba9da3075cda0445c44a4bb00))
- **node:** fix broken tests due to invalid error line parsing
  ([1337d5c9](https://github.com/abe33/spectacular/commit/1337d5c93651cce428ddc0db6a1ee733650e7060))
- **phantomjs:**
  - remove String prototype decoration to avoid error on travis
  ([ee643e1a](https://github.com/abe33/spectacular/commit/ee643e1aa8272e751edae8d1b4bef543be4b77fd))
  - fix missed tests before the console reporter registration
  ([75747a3f](https://github.com/abe33/spectacular/commit/75747a3fc398cd2d24bccaba5b44bc8486e0c627))
  - fix broken stack trace line parsing on PhantomJS
  ([297353c7](https://github.com/abe33/spectacular/commit/297353c7324b975c2737b92844d1b0060a89bb8d))
- **server:** vendor files should be served from spectacular directory
  ([006f2012](https://github.com/abe33/spectacular/commit/006f20126183cf2dfa957ccb2fbd561ebe85f057))
- **source-map:** use a fixed version of source-map for PhantomJS
  ([11dfe0df](https://github.com/abe33/spectacular/commit/11dfe0dfc4be28bc161b640947c531c4fe2a1a2c))
- **tests:** fix broken tests on Internet Explorer 9
  ([558166e7](https://github.com/abe33/spectacular/commit/558166e7f5c88b07c96b9382d52af9bc43050d94))


## Features

- **source-map:** implements source map support for both node and browsers
  ([2783b975](https://github.com/abe33/spectacular/commit/2783b975110d1a2f3232d8ba02e93843a31e006c), [77c5c7f5](https://github.com/abe33/spectacular/commit/77c5c7f58b2436a13ec03911ba4e74cae5e6d921), [#6](https://github.com/abe33/spectacular/issues/6))


<a name="1.3.1"></a>
# 1.3.1 (2013-07-23)


## Bug Fixes

- **$cli:** fix broken formatting of documentation format
  ([04372a98](https://github.com/abe33/spectacular/commit/04372a988df4bd66593fa7fc985503708e7f5e70),
   [#4](https://github.com/abe33/spectacular/issues/4))
- **pages:** add missing link to v1.2.1 documentation
  ([ad666c01](https://github.com/abe33/spectacular/commit/ad666c01296f0f5060df21af5ccbe7c65a66e205))


## Features

- **$npm:** add contributors section in package.json
  ([79bb90a7](https://github.com/abe33/spectacular/commit/79bb90a7f3a7dba74c15d3e78d6c5126514a90d1),
   [#5](https://github.com/abe33/spectacular/issues/5))
- **matchers:** beWithin(delta).of(expected) matcher for floating point expectiations
  ([8797e6f4](https://github.com/abe33/spectacular/commit/8797e6f427ed86d82fc1df465ab91ea6b9b3a83a))



<a name="1.3.0"></a>
# 1.3.0 (2013-07-23)


## Bug Fixes

- **$browser:** the options and paths are no longer passed though window
  ([ec776202](https://github.com/abe33/spectacular/commit/ec7762022e8283b918bc0b080749e9e98127e004))
- **cli:** fix typo on event listener registration
  ([9f4f4dcb](https://github.com/abe33/spectacular/commit/9f4f4dcb4e438f1d990cb50526cbc6480fb95157))

## Features

- **$travis:** add slimerjs tests on travis
  ([af948b5b](https://github.com/abe33/spectacular/commit/af948b5ba4cc17e0b903bbdb84aab4bedaed6443))
- **matchers:** registered matchers now automacally stores their name
  ([c4a3112b](https://github.com/abe33/spectacular/commit/c4a3112ba19128fe49c524a08e880c07a18dd185))


## Breaking Changes

- **$browser:** due to [ec776202](https://github.com/abe33/spectacular/commit/ec7762022e8283b918bc0b080749e9e98127e004),
  the options and paths are now retrieved from the
  spectacular object, it's no longer effective to set it on window.

    To migrate the code simply replace :

    ```coffeescript
    window.options = # ...
    ```

    With:

    ```coffeescript
    spectacular.options = # ...
    ```


<a name="1.2.1"></a>
# 1.2.1 (2013-07-14)


## Bug Fixes

- **documentation:** update documentation with latest options and commands
  ([4d281ea1](https://github.com/abe33/spectacular/commit/4d281ea19e8e3afae2b1e4225411ba2418b7e55d))



<a name="1.2.0"></a>
# 1.2.0 (2013-07-14)


## Bug Fixes

- **$core:** retrieve nextTick or setImmediate from window if available
  ([47e5c1e1](https://github.com/abe33/spectacular/commit/47e5c1e167758525d32ccadf00fad4ea2bf395d7))
- **browser:** fix hidden errors when the parent group already had success
  ([edfbc739](https://github.com/abe33/spectacular/commit/edfbc7390fec147cbfd278f4186ada92ed0ba732))
- **examples:** fix false positive with ExampleGroup::failed
  ([f0f965bf](https://github.com/abe33/spectacular/commit/f0f965bf2bef414e9b204c66be8cab50eeeef77f))
- **phantomjs:**
  - fix server port never passed to phantomjs script
  ([0c653fe2](https://github.com/abe33/spectacular/commit/0c653fe2b145bf5dad83aa8f7d9533e3ca7af08d))
- **promises:** fix value changed after a second resolve call
  ([f7a4c134](https://github.com/abe33/spectacular/commit/f7a4c1349680ceba292f99081c413edee70cd886))


## Features

- **$bin:**
  - add a --phantom-bin option to pass the path to phantomjs
  ([9a745114](https://github.com/abe33/spectacular/commit/9a745114cb6c161f21d7ce7a02b1b44615dd5021))
  - use command like arguments for run mode
  ([2769b92a](https://github.com/abe33/spectacular/commit/2769b92a012a80ae2fdd9191e7e58dcba685e0d9))
- **$core:**
  - add support for SlimerJS
  ([eec62aa2](https://github.com/abe33/spectacular/commit/eec62aa2f89e65ab6ecebe1c445a0c481b2d8c31))
  - add a deprecated method to offer proper deprecation messages
  ([87c68336](https://github.com/abe33/spectacular/commit/87c6833675d6ebd13fc669f937c22ee20b8ae78e))
- **browser:**
  - clicking on an error stack line will load the source
  ([fe5991d9](https://github.com/abe33/spectacular/commit/fe5991d973284cda7e8c23a01d556d2be2cbc94e))
  - add documentation format for browser runner
  ([d1aff64c](https://github.com/abe33/spectacular/commit/d1aff64c1fe7e8ad281654b1382b2164299c8fef))
- **examples:** add support of `#` as instance member descriptor
  ([ca9fdf69](https://github.com/abe33/spectacular/commit/ca9fdf699eecf9ed9a6acaf8a54f497f1ce33cb1))
- **factories:**
  - add factory build hooks
  ([19046214](https://github.com/abe33/spectacular/commit/19046214b2b636a3cda3e96f7716de1bbdee58bd))
  - add support for factory mixin
  ([61ba355d](https://github.com/abe33/spectacular/commit/61ba355d768d9da44df013f55e26bed0ad94fbfd))
  - add support for custom build in factories
  ([e7daeb3c](https://github.com/abe33/spectacular/commit/e7daeb3ceda4d18f3191eede8d736bbfb72e3aea))
- **server:** add logs and verbose outputs to the server
  ([6633138b](https://github.com/abe33/spectacular/commit/6633138b7426b2078ca7f11234ac65435a4c50e8))


## Breaking Changes

- **$bin:** due to [2769b92a](https://github.com/abe33/spectacular/commit/2769b92a012a80ae2fdd9191e7e58dcba685e0d9),
  running the spectacular bin without a command will only
  display the help message

  To run the test you must you the `test` command such :

    `spectacular test`


<a name="1.1.0"></a>
# 1.1.0 (2013-07-06)


## Bug Fixes

- **$browser:** fix invalid lookup in hasClass
  ([4b71516f](https://github.com/abe33/spectacular/commit/4b71516f741442cd314e745e7491d0f2c57c42ec))
- **examples:**
  - passing `undefined` to `describe` is now a valid subject
  ([47a3d691](https://github.com/abe33/spectacular/commit/47a3d6912fb63f923e78a52253f8980a30eb54c4))
  - examples groups without examples are now pending
  ([2730c459](https://github.com/abe33/spectacular/commit/2730c459aa7e843a73da54d639430e10308aee16))
- **server:**
  - make sure that paths only contains unique entries
  ([5855a220](https://github.com/abe33/spectacular/commit/5855a220b6be0fcf7456d81b32527cb95fdc3eca))
  - the paths was sliced one item too early
  ([1d08c578](https://github.com/abe33/spectacular/commit/1d08c5785b0d32928dc97febbb042b67737a5570))
  - fix undefined present in paths array
  ([384358f6](https://github.com/abe33/spectacular/commit/384358f6e1aefa57a94fba9e7fa8ebf6b158ced7))


## Features

- **$browser:**
  - add verbose output through console.log
  ([ecdc0c89](https://github.com/abe33/spectacular/commit/ecdc0c89fdedb8547f8305f4f90ed517b6a14dbd))
  - automatically hide success on the first failure
  ([f19fab78](https://github.com/abe33/spectacular/commit/f19fab78e38e18c76d3c412b13bae35e56d950a8))
- **$cli:** add --colors options that forces the coloring
  ([79c9b334](https://github.com/abe33/spectacular/commit/79c9b334835e5c61ca4ac6128e7c1b58ce3ecd8b))
- **$core:** unmet dependencies no longer raise an exception
  ([3ac6d55f](https://github.com/abe33/spectacular/commit/3ac6d55fb8c6dcbbebefd4391387a95c82c1c70d))
- **mixins:** add proper mixins methods
  ([d37e24c2](https://github.com/abe33/spectacular/commit/d37e24c22cad31b782edf519f6911bd75a0c43e1))
- **runner:**
  - add seeded random for tests
  ([03f2aca1](https://github.com/abe33/spectacular/commit/03f2aca130cb39c6590ed7c4061fae18e421d0b0))
  - add random execution as default behavior
  ([ddbe3bdb](https://github.com/abe33/spectacular/commit/ddbe3bdbf9223d79e94667523aac486265eb5664))


## Breaking Changes

- **mixins:** due to [d37e24c2](https://github.com/abe33/spectacular/commit/d37e24c22cad31b782edf519f6911bd75a0c43e1),
  the `Globalizable` mixin can no longer define and use
  an `excluded` static property, then it was renamed as `unglobalizable`.



<a name="1.0.2"></a>
# 1.0.2 (2013-06-26)


## Bug Fixes

- **server:** fix broken walkdir in server when directories don't exists
  ([0e642d4a](https://github.com/abe33/spectacular/commit/0e642d4a62dd1d1ea6295f835cb4b81100f654bb))



<a name="1.0.1"></a>
# 1.0.1 (2013-06-26)


## Bug Fixes

- **$bin:** server option didn't turn cli off
  ([087dbf06](https://github.com/abe33/spectacular/commit/087dbf06d3b45320ccae211e51e8cb192a5b3db6))



<a name="1.0.0"></a>
# 1.0.0 (2013-06-23)


## Bug Fixes

- **$tests:**
  - tests broken on node v0.10.9
  ([cf3e1c61](https://github.com/abe33/spectacular/commit/cf3e1c611cc3d660badf497ff12a5841de345987))
  - fix false positive on travis with failure only in node
  ([23b32f0a](https://github.com/abe33/spectacular/commit/23b32f0a29ed558a8ed61f2ea05dad779d6ce6db))
- **cli:** fix broken walkdir call if path doesn't exist
  ([1d2d30e5](https://github.com/abe33/spectacular/commit/1d2d30e52a371f70e88eb5744b8026f48348d888))
- **matchers:**
  - fix missing diff in equal message
  ([5242a363](https://github.com/abe33/spectacular/commit/5242a363c33da1144b6bee678f5661d71f5f3e8c))
  - fix invalid message for haveBeenCalled
  ([e92d8355](https://github.com/abe33/spectacular/commit/e92d83558fce4f0a0e28252ccabe9cb515b9c402))
- **phantomjs:** defining a property without a setter on an object failed
  ([7025b979](https://github.com/abe33/spectacular/commit/7025b979052bbdd68e211d32e81dd75941036efd))


## Features

- **$bin:** add help and version options
  ([36b80595](https://github.com/abe33/spectacular/commit/36b80595332f4e84198914c5d6ae06729c837625))
- **factories:** implements factory inheritance
  ([19e19039](https://github.com/abe33/spectacular/commit/19e19039ed68e2ed058ce119e04d3d168d965816))
- **matchers:**
  - implements init hooks on matcher creation
  ([80ee4a9d](https://github.com/abe33/spectacular/commit/80ee4a9dbc2186b21b4227ddbb5ab0dad71ca3bf))
  - implements support for full rspec syntax
  ([62460189](https://github.com/abe33/spectacular/commit/62460189bb9772917a0551260ea389eb28fff32c))


## Breaking Changes

- **matchers:** due to [62460189](https://github.com/abe33/spectacular/commit/62460189bb9772917a0551260ea389eb28fff32c),
  matchers no longer can be defined as an object, the use of the spectacular helper is mandatory.

    To migrate the code follow the example below:

    ```coffeescript
    exports.myMatcher = (value) ->
      match: (actual) ->
        @description = '...'
        @message = '...'
        actual is value
    ```
    After:

    ```coffeescript
    spectacular.matcher 'myMatcher', ->
      takes 'value'
      description -> '...'
      failureMessageForShould -> '...'
      match (actual) -> actual is @value
    ```

<a name="0.0.4"></a>
# 0.0.4 (2013-06-15)


## Bug Fixes

- **$tests:** fix broken travis tests due to server tests
  ([0f79ccd5](https://github.com/abe33/spectacular/commit/0f79ccd52c6f7f78a55392509164fe4ef8313fff))


<a name="0.0.3"></a>
# 0.0.3 (2013-06-15)


## Bug Fixes

- **$bin:** fix bad reading of paths options
  ([88d0962e](https://github.com/abe33/spectacular/commit/88d0962edc5bebf95e628ed606cc783bca16ed05))
- **$browser:** run a previouly registered window.onload event
  ([96515389](https://github.com/abe33/spectacular/commit/96515389fdc6d2d2bb1c54ceb7f6db406055e428))
- **$tests:** force documentation format for expect tests
  ([d94c9ed8](https://github.com/abe33/spectacular/commit/d94c9ed835614674fd4d16f957b5a3fdb35c1cb0))
- **environment:** unglobalize environment after tests
  ([975c4edc](https://github.com/abe33/spectacular/commit/975c4edc642499514b6521e144b30b7892c6be90))


## Features

- **$bin:**
  - add support for config file
  ([8ffb526c](https://github.com/abe33/spectacular/commit/8ffb526c2aed7a19ccd276b0694d19d5c6b3e9a6))
  - implements phantomjs support in the spectacular bin
  ([a15d14c7](https://github.com/abe33/spectacular/commit/a15d14c79f5f37ba0955b24cf261a1be0f36817f))
- **$core:** snakify matchers and matchers methods
  ([944f9f66](https://github.com/abe33/spectacular/commit/944f9f66e07e382178a2138e2f20c324fb341a76))
- **$tests:** helpers are now created with spectacular.helper
  ([a8b1f6c1](https://github.com/abe33/spectacular/commit/a8b1f6c1151d5b5e3d7c8de7b22c8bc1ad6fb0c1))
- **Cakefile:** add browser packaging task
  ([acd9f1a6](https://github.com/abe33/spectacular/commit/acd9f1a67c55644b7e4d416cf5f301cf3b125f7d))
- **browser:**
  - browser reporter provides default options if not provided
  ([c266c1fa](https://github.com/abe33/spectacular/commit/c266c1fa62fe931e218c99d24b8c425073030d2b))
  - specs filters position is now relative to the reporter
  ([946d7573](https://github.com/abe33/spectacular/commit/946d757376dc79d0d4f0cd0e0366f04a145e7ba9))
- **docs:** run the spectaculars specs in the documentation
  ([b843a184](https://github.com/abe33/spectacular/commit/b843a184c179130b4303d025855d2bddabdb86c6))
- **matchers:** provides rspec style matcher definition
  ([bb413b7b](https://github.com/abe33/spectacular/commit/bb413b7bcac297876a6fb672595f3455329143ef))
- **mixins:**
  - support original method in snake case in Globalizable
  ([6bc5771a](https://github.com/abe33/spectacular/commit/6bc5771abe5fce6d94c161c6bba57891a67735a7))
  - add set method on GlobalizableObject
  ([b42a28c9](https://github.com/abe33/spectacular/commit/b42a28c96ca9ed4eb1f0de51f997680c8c7c74ff))
- **server:**
  - add support for source files
  ([826abfc3](https://github.com/abe33/spectacular/commit/826abfc3474b8ed08e15e6a908c24957b6ee5dca))
  - server port can now be defined using PORT environment variable
  ([60ddb050](https://github.com/abe33/spectacular/commit/60ddb050a87914e897b2a0f1099a3c221fd78021))



<a name="0.0.2"></a>
# 0.0.2 (2013-06-11)


## Bug Fixes

- **environment:** unglobalize environment after tests
  ([975c4edc](https://github.com/abe33/spectacular/commit/975c4edc642499514b6521e144b30b7892c6be90))


## Features

- **$core:** snakify matchers and matchers methods
  ([944f9f66](https://github.com/abe33/spectacular/commit/944f9f66e07e382178a2138e2f20c324fb341a76))
- **$tests:** helpers are now created with spectacular.helper
  ([a8b1f6c1](https://github.com/abe33/spectacular/commit/a8b1f6c1151d5b5e3d7c8de7b22c8bc1ad6fb0c1))
- **matchers:** provides rspec style matcher definition
  ([bb413b7b](https://github.com/abe33/spectacular/commit/bb413b7bcac297876a6fb672595f3455329143ef))
- **mixins:**
  - support original method in snake case in Globalizable
  ([6bc5771a](https://github.com/abe33/spectacular/commit/6bc5771abe5fce6d94c161c6bba57891a67735a7))
  - add set method on GlobalizableObject
  ([b42a28c9](https://github.com/abe33/spectacular/commit/b42a28c96ca9ed4eb1f0de51f997680c8c7c74ff))
