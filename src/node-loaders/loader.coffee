fs = require 'fs'
#
# Defines an abstract interface that subclasses should override to
# load specific languages that compile down to javascript.
#
class Loader

  # Is passed the blanket instance that is instrumenting the code
  # as well as the file extension (including the '.'), that will
  # be used on files of that extension.
  constructor: (@blanket, @extension)->
    throw Error('Extension is required!') unless @extension
    @oldLoader = require.extensions[@extension]
    require.extensions[@extension] = (localModule, filename)=>
      originalFilename = filename
      inputFilename = filename
      filename = @blanket.normalizeBackslashes(filename)

      # We test the antipattern first in case there is overlap
      # between the two folders, we ensure we don't include something
      # we should not. Negative wins.
      if @matchesAntipattern(filename)
        @oldRead(localModule, filename)
      else if @matches(filename)
        @compile @read(filename), filename, (instrumented)=>
          baseDirPath = blanket.normalizeBackslashes(path.dirname(filename)) + '/.'
          try
            instrumented = instrumented.replace(/require\s*\(\s*("|')\./g,'require($1'+baseDirPath)
            localModule._compile(instrumented, originalFilename)
          catch err
            if @blanket.options("ignoreScriptError")
              # we can continue like normal if
              # we're ignoring script errors,
              # but otherwise we don't want
              # to completeLoad or the error might be
              # missed.
              if @blanket.options("debug")
                console.log("BLANKET-There was an error loading the file:"+filename)
              oldLoader(localModule,filename)
            else
              throw new Error("BLANKET-Error parsing instrumented code: "+err)
      else
        @oldRead(localModule, filename)


  # TEST this antipattern bullshit
  matchesAntipattern: (filename)->
    antipattern = @blanket.options('antifilter')
    regex = new RegExp('\\' + @extension + '$')

    if typeof(antipattern) isnt 'undefined'
      return @blanket.matchPattern(filename.replace(regex, ''), antipattern)
    return no

  matches: (filename)->
    pattern = @blanket.options('filter')
    @blanket.matchPattern(filename, pattern)

  read: (filename)->
    reporter_options = @blanket.options('reporter_options')
    content = fs.readFileSync(filename, 'utf8')

    # if we have a magic way of "getting" properties, it should handle nested
    # properties. Not magic, just private w/ getter
    if reporter_options and reporter_options.shortnames
      inputFilename = filename.replace(path.dirname(filename),"")

    if reporter_options and reporter_options.basepath
      inputFilename = filename.replace(reporter_options.basepath + '/',"")

    contents: content, filename: inputFilename

  oldRead: (localModule, filename)->
    @oldLoader(localModule, filename)

  # Subclasses MUST override
  compile: (contents, filename, next)->
    throw new Error('Not Implemented!')

module.exports = Loader
