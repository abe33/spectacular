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
