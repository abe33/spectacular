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
