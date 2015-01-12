#
#
#
extend = require 'xtend'
path = require 'path'
join = path.join
fs = require 'fs'
configPath = join process.cwd(), 'package.json'
file = if fs.existsSync(configPath) then JSON.parse(fs.readFileSync(configPath) or {}) else null
packageConfigs = null

# I am convinced the 'cli' option actually does nothing.
# So there's that.
blanketNode = (userOptions)->
  if file
    scripts = file.scripts
    config = file.config
    packageConfigs = config.blanket if config and config.blanket

  blanketConfigs = if packageConfigs then extend(packageConfigs,userOptions) else userOptions
  pattern = if blanketConfigs then blanketConfigs.pattern else "src"
  blanket = require('./blanket').blanket

  # This is, erm, deprecated.
  # http://nodejs.org/api/globals.html#globals_require_extensions
  # "Since the Module system is locked, this feature will probably
  # never go away. However, it may have subtle bugs and complexities
  # that are best left untouched."
  #
  # Okay, well, that's enlightening. We should probably not use this.
  oldLoader = require.extensions['.js']
  newLoader = null;

  escapeRegExp = (str)->
    str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

  #
  # Ugh, there must be a better way to do this.
  #
  if blanketConfigs
    newOptions = {}
    Object.keys(blanketConfigs).forEach (option)->
      optionValue = blanketConfigs[option]
      if option is 'data-cover-only' or option is 'pattern'
        newOptions.filter = optionValue

      if option is 'data-cover-never'
        newOptions.antifilter = optionValue

      # Try and remove this later with smart loading.
      if option is 'data-cover-loader' or option is 'loader'
        newOptions.loader = optionValue

      if option is 'data-cover-timeout'
        newOptions.timeout = optionValue

      if option is 'onlyCwd' and !!optionValue
        newOptions.cwdRegex = new RegExp("^" + escapeRegExp(process.cwd()), "i")

      if option is 'data-cover-customVariable'
        newOptions.customVariable = optionValue

      if option is 'data-cover-flags'
        newOptions.order = !optionValue.unordered
        newOptions.ignoreScriptError = !!optionValue.ignoreError
        newOptions.autoStart = !!optionValue.autoStart
        newOptions.branchTracking = !!optionValue.branchTracking
        newOptions.debug = !!optionValue.debug
        newOptions.engineOnly = !!optionValue.engineOnly

      if option is 'data-cover-reporter-options'
        newOptions.reporter_options = optionValue

    blanket.options(newOptions)

  # Why are these not in the main blanket
  # file?
  #
  # helper functions
  blanket.normalizeBackslashes = (str)->
    str.replace(/\\/g, '/')


  blanket.restoreNormalLoader = ->
    if not blanket.options('engineOnly')
      newLoader = require.extensions['.js']
      require.extensions['.js'] = oldLoader


  blanket.restoreBlanketLoader = ->
    if not blanket.options('engineOnly')
      require.extensions['.js'] = newLoader


  # you can pass in a string, a regex, or an array of files
  blanket.matchPattern = (filename,pattern)->
    cwdRegex = blanket.options('cwdRegex')
    if cwdRegex and not cwdRegex.test(filename)
      return false

    if typeof pattern is 'string'
      if pattern.indexOf('[') is 0
        # treat as array
        pattenArr = pattern.slice(1, pattern.length - 1).split(',')
        return pattenArr.some (elem)->
          blanket.matchPattern(filename, blanket.normalizeBackslashes(elem.slice(1,-1)))

      else if pattern.indexOf('//') is 0
        ex = pattern.slice(2, pattern.lastIndexOf('/'))
        mods = pattern.slice(pattern.lastIndexOf('/')+1)
        regex = new RegExp(ex, mods)
        return regex.test(filename)
      else
        return filename.indexOf(blanket.normalizeBackslashes(pattern)) > -1

    else if Array.isArray(pattern)
      return pattern.some (elem)->
        filename.indexOf(blanket.normalizeBackslashes(elem)) > -1

    else if pattern instanceof RegExp
      return pattern.test(filename)
    else if typeof pattern is 'function'
      return pattern(filename)
    else
      throw Error("Bad file instrument indicator.  Must be a string, regex, function, or array.")

  # Last Option.
  # Need to look into this "engineonly" thing
  if not blanket.options('engineOnly')
    # instrument js files
    # Oh fuck, I see what's happening here. The docs explicitely say not to
    # do this, lol. I'll need to run some testing to see how this works
    # with the values.
    ###
    { id: '/Users/ethan/Documents/blanket/test/fixture/test/testA.js',
    exports: {},
    parent:
     { id: '/Users/ethan/Documents/blanket/test/tests/nested_test.js',
       exports: {},
       parent:
        { id: '/Users/ethan/Documents/blanket/test/testrunner.js',
          exports: {},
          parent: [Object],
          filename: '/Users/ethan/Documents/blanket/test/testrunner.js',
          loaded: false,
          children: [Object],
          paths: [Object] },
       filename: '/Users/ethan/Documents/blanket/test/tests/nested_test.js',
       loaded: false,
       children: [ [Circular] ],
       paths:
        [ '/Users/ethan/Documents/blanket/test/tests/node_modules',
          '/Users/ethan/Documents/blanket/test/node_modules',
          '/Users/ethan/Documents/blanket/node_modules',
          '/Users/ethan/Documents/node_modules',
          '/Users/ethan/node_modules',
          '/Users/node_modules',
          '/node_modules' ] },
    filename: '/Users/ethan/Documents/blanket/test/fixture/test/testA.js',
    loaded: false,
    children: [],
    paths:
     [ '/Users/ethan/Documents/blanket/test/fixture/test/node_modules',
       '/Users/ethan/Documents/blanket/test/fixture/node_modules',
       '/Users/ethan/Documents/blanket/test/node_modules',
       '/Users/ethan/Documents/blanket/node_modules',
       '/Users/ethan/Documents/node_modules',
       '/Users/ethan/node_modules',
       '/Users/node_modules',
       '/node_modules' ] }
    ###

    require.extensions['.js'] = (localModule, filename)->
      pattern = blanket.options('filter')
      reporter_options = blanket.options('reporter_options')
      originalFilename = filename
      inputFilename = filename
      filename = blanket.normalizeBackslashes(filename)

      # we check the never matches first
      antipattern = blanket.options('antifilter')
      if typeof antipattern isnt 'undefined' and blanket.matchPattern(filename.replace(/\.js$/,""), antipattern)
        oldLoader(localModule, filename)
        # I hate this manner of debugging. Export it to a 'log' module.
        if blanket.options("debug")
          console.log("BLANKET-File will never be instrumented:" + filename)
      else if blanket.matchPattern(filename,pattern)
        console.log("BLANKET-Attempting instrument of:"+filename) if blanket.options("debug")
        content = fs.readFileSync(filename, 'utf8')

        # if we have a magic way of "getting" properties, it should handle nested
        # properties. Not magic, just private w/ getter
        if reporter_options and reporter_options.shortnames
          inputFilename = filename.replace(path.dirname(filename),"")

        if reporter_options and reporter_options.basepath
          inputFilename = filename.replace(reporter_options.basepath + '/',"")

        # Wooooo, magic.
        blanket.instrument {
          inputFile: content
          inputFileName: inputFilename
        }, (instrumented)->
          baseDirPath = blanket.normalizeBackslashes(path.dirname(filename)) + '/.'
          try
            instrumented = instrumented.replace(/require\s*\(\s*("|')\./g,'require($1'+baseDirPath)
            localModule._compile(instrumented, originalFilename)
          catch err
            if blanket.options("ignoreScriptError")
              # we can continue like normal if
              # we're ignoring script errors,
              # but otherwise we don't want
              # to completeLoad or the error might be
              # missed.
              if blanket.options("debug")
                console.log("BLANKET-There was an error loading the file:"+filename)
              oldLoader(localModule,filename)
            else
              throw new Error("BLANKET-Error parsing instrumented code: "+err)

      else
        oldLoader(localModule, originalFilename)

  # if a loader is specified, use it
  # We should load up all loaders on demand.
  if blanket.options("loader")
    require(blanket.options("loader"))(blanket)

  newLoader = require.extensions['.js']
  blanket

# Start!
if (process.env and process.env.BLANKET_COV is 1) or (process.ENV and process.ENV.BLANKET_COV)
  module.exports = blanketNode( engineOnly: yes )
else
  args = process.argv
  blanketRequired = no

  for val, i in args
    blanketRequired = yes if ['-r', '--require'].indexOf(val) > -1 and args[i + 1] is 'blanket'

  if args[0] is 'node' and args[1].indexOf(join('node_modules','mocha','bin')) > -1 and blanketRequired
    # using mocha cli
    # This is broken, I don't start mocha this way.
    module.exports = blanketNode( null )
  else
    # not mocha cli
    module.exports = (options)->
      # we don't want to expose the cli option.
      blanketNode(options)