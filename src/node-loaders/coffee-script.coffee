fs = require 'fs'
path = require 'path'
coffeeScript = require 'coffee-script'
log = require '../log'

module.exports = (blanket)->
  oldLoaderCS = require.extensions['.coffee']

  require.extensions['.coffee'] = (localModule, filename)->
    pattern = blanket.options('filter')
    reporter_options = blanket.options('reporter_options')
    originalFilename = filename
    inputFilename = filename
    filename = blanket.normalizeBackslashes(filename)
    antipattern = blanket.options('antifilter')

    if typeof(antipattern) isnt 'undefined' and blanket.matchPattern(filename.replace(/\.js$/,""), antipattern)
      oldLoaderCS(localModule,filename)
      log.debug("BLANKET-File will never be instrumented: #{filename}")

    else if blanket.matchPattern(filename,pattern)
      log.debug "BLANKET-Attempting instrument of: #{filename}"
      content = fs.readFileSync(filename, 'utf8')
      if reporter_options and reporter_options.shortnames
        inputFilename = filename.replace(process.cwd(),'').replace('/', '')

      if reporter_options and reporter_options.basepath
        inputFilename = filename.replace(reporter_options.basepath + '/',"")

      content = coffeeScript.compile(content)
      blanket.instrument {
        inputFile: content
        inputFileName: inputFilename
      }, (instrumented)->
        baseDirPath = blanket.normalizeBackslashes(path.dirname(filename)) + '/.'
        try
          instrumented = instrumented.replace(/require\s*\(\s*("|')\./g,'require($1'+baseDirPath)
          localModule._compile(instrumented, originalFilename)
        catch err
          log.error 'Error parsing instrumented code: ', err
          throw new Error("BLANKET-Error parsing instrumented code: " + err)
    else
      oldLoaderCS(localModule, originalFilename)
