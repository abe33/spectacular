fs = require 'fs'

module.exports = (env, callback) ->

  class FixturePlugin extends env.ContentPlugin

    constructor: (@filepath, @text) ->

    getFilename: -> @filepath.relative

    getView: -> (env, locals, contents, templates, callback) ->
      callback null, new Buffer @text

  FixturePlugin.fromFile = (filepath, callback) ->
    fs.readFile filepath.full, (error, buffer) ->
      if error
        callback error
      else
        callback null, new FixturePlugin filepath, buffer.toString()

  env.registerContentPlugin 'text', 'js/fixtures/*.*', FixturePlugin
  callback() # tell the plugin manager we are done
