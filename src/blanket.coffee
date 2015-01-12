parseAndModify = require 'falafel'

copynumber = Math.floor(Math.random()*1000)
coverageInfo = {}
options =
  reporter: null
  adapter: null
  filter: null
  customVariable: null
  loader: null
  ignoreScriptError: no,
  existingRequireJS: no
  autoStart: no
  timeout: 180
  ignoreCors: no
  branchTracking: no
  sourceURL: no
  debug: off
  engineOnly: no
  testReadyCallback: null
  commonJS: no
  instrumentCache: no
  modulePattern: null

class Blanket

  constructor: ->
    @_trackingArraySetup = []
    @_branchingArraySetup = []
    @linesToAddTracking = [
      'ExpressionStatement'
      'BreakStatement'
      'ContinueStatement'
      'VariableDeclaration'
      'ReturnStatement'
      'ThrowStatement'
      'TryStatement'
      'FunctionDeclaration'
      'IfStatement'
      'WhileStatement'
      'DoWhileStatement'
      'ForStatement'
      'ForInStatement'
      'SwitchStatement'
      'WithStatement'
    ]
    @linesToAddBrackets = [
      'IfStatement'
      'WhileStatement'
      'DoWhileStatement'
      'ForStatement'
      'ForInStatement'
      'WithStatement'
    ]


  _getCopyNumber: ->
    # internal method
    # for differentiating between instances
    copynumber

  extend: (obj)->
    # borrowed from underscore
    @_extend(this, obj)

  _extend: (dest, source)->
    if source
      for key, value of source
        if dest[key] instanceof Object and typeof dest[key] isnt 'function'
          @_extend(dest[key], source[key])
        else
          dest[key] = value

  getCovVar: ->
    opt = @options('customVariable')
    if opt
      console.log("BLANKET-Using custom tracking variable:", opt) if @options('debug')
      return opt

    return "_$jscoverage" #ugh.

  # This is how we are doing options, but it doesn't handle
  # nested elements, NOR DO WE USE IT EVERYWHERE
  options: (key, value)->
    if typeof key isnt 'string'
      @_extend(options, key)
    else if typeof value is 'undefined'
      return options[key]
    else
      options[key] = value

  #
  # Magic!
  #
  instrument: (config, next)->
    # check instrumented hash table,
    # return instrumented code if available.
    inFile = config.inputFile
    inFileName = config.inputFileName
    # check instrument cache
    if @options('instrumentCache') and sessionStorage and sessionStorage.getItem('blanket_instrument_store-' + inFileName)
      if @options('debug')
        console.log("BLANKET-Reading instrumentation from cache: ", inFileName)

      next(sessionStorage.getItem("blanket_instrument_store-" + inFileName))
    else
      sourceArray = @_prepareSource(inFile)
      @_trackingArraySetup = []
      # remove shebang
      inFile = inFile.replace(/^\#\!.*/, "")
      instrumented = parseAndModify(inFile, {loc:true,comment:true}, @_addTracking(inFileName))
      instrumented = @_trackingSetup(inFileName,sourceArray) + instrumented
      if @options("sourceURL")
        instrumented += "\n//@ sourceURL="+inFileName.replace("http://","")

      console.log("BLANKET-Instrumented file: ",inFileName) if @options("debug")
      if @options("instrumentCache") and sessionStorage
        console.log("BLANKET-Saving instrumentation to cache: ", inFileName) if @options("debug")
        sessionStorage.setItem("blanket_instrument_store-"+inFileName,instrumented)

      next(instrumented)

  _prepareSource: (source)->
    source.replace(/\\/g,"\\\\").replace(/'/g,"\\'").replace(/(\r\n|\n|\r)/gm,"\n").split('\n')

  _trackingSetup: (filename, sourceArray)->
    branches = @options("branchTracking")
    sourceString = sourceArray.join("',\n'")
    intro = ''
    covVar = @getCovVar()

    intro += "if (typeof "+covVar+" === 'undefined') "+covVar+" = {};\n"
    if branches
      intro += "var _$branchFcn=function(f,l,c,r){ "
      intro += "if (!!r) { "
      intro += covVar+"[f].branchData[l][c][0] = "+covVar+"[f].branchData[l][c][0] || [];"
      intro += covVar+"[f].branchData[l][c][0].push(r); }"
      intro += "else { "
      intro += covVar+"[f].branchData[l][c][1] = "+covVar+"[f].branchData[l][c][1] || [];"
      intro += covVar+"[f].branchData[l][c][1].push(r); }"
      intro += "return r;};\n"

    intro += "if (typeof "+covVar+"['"+filename+"'] === 'undefined'){"
    intro += covVar+"['"+filename+"']=[];\n"

    if branches
      intro += covVar+"['"+filename+"'].branchData=[];\n"

    intro += covVar+"['"+filename+"'].source=['"+sourceString+"'];\n"
    # initialize array values
    @_trackingArraySetup.sort (a,b)->
      parseInt(a, 10) > parseInt(b,10)
    .forEach (item)->
      intro += covVar+"['"+filename+"']["+item+"]=0;\n"

    if branches
      @_branchingArraySetup.sort (a,b)->
        a.line > b.line
      .sort (a,b)->
        a.column > b.column
      .forEach (item)->
        if item.file is filename
          intro += "if (typeof "+ covVar+"['"+filename+"'].branchData["+item.line+"] === 'undefined'){\n"
          intro += covVar+"['"+filename+"'].branchData["+item.line+"]=[];\n"
          intro += "}"
          intro += covVar+"['"+filename+"'].branchData["+item.line+"]["+item.column+"] = [];\n"
          intro += covVar+"['"+filename+"'].branchData["+item.line+"]["+item.column+"].consequent = "+JSON.stringify(item.consequent)+";\n"
          intro += covVar+"['"+filename+"'].branchData["+item.line+"]["+item.column+"].alternate = "+JSON.stringify(item.alternate)+";\n"
    intro += "}"
    return intro

  _blockifyIf: (node)->
    if @linesToAddBrackets.indexOf(node.type) > -1
      bracketsExistObject = node.consequent or node.body
      bracketsExistAlt = node.alternate
      if bracketsExistAlt and bracketsExistAlt.type isnt 'BlockStatement'
        bracketsExistAlt.update('{\n' + bracketsExistAlt.source() + '}\n')

      if bracketsExistObject and bracketsExistObject.type isnt 'BlockStatement'
        bracketsExistObject.update('{\n' + bracketsExistObject.source() + '}\n')



  _trackBranch: (node, filename)->
    # recursive on consequent and alternative
    line = node.loc.start.line
    col = node.loc.start.column

    @_branchingArraySetup.push
      line: line
      column: col
      file:filename
      consequent: node.consequent.loc
      alternate: node.alternate.loc

    updated = "_$branchFcn"+
        "('"+filename+"',"+line+","+col+","+node.test.source()+
        ")?"+node.consequent.source()+":"+node.alternate.source()
    node.update(updated)

  _addTracking: (filename)->
    # falafel doesn't take a file name
    # so we include the filename in a closure
    # and return the function to falafel
    covVar = @getCovVar()

    return (node)=>
      @_blockifyIf(node)

      if @linesToAddTracking.indexOf(node.type) > -1 and node.parent.type isnt 'LabeledStatement'
        @_checkDefs(node,filename)
        if node.type is 'VariableDeclaration' and (node.parent.type is 'ForStatement' or node.parent.type is 'ForInStatement')
          return

        if node.loc and node.loc.start
          node.update(covVar+"['"+filename+"']["+node.loc.start.line+"]++;\n"+node.source())
          @_trackingArraySetup.push(node.loc.start.line)
        else
          # I don't think we can handle a node with no location
          throw new Error("The instrumenter encountered a node with no location: "+Object.keys(node));
      else if @options("branchTracking") and node.type is 'ConditionalExpression'
        @_trackBranch(node,filename)


  _checkDefs: (node, filename)->
    # Make sure developers don't redefine the coverage variable in node
    if (node.type is 'ExpressionStatement' and
        node.expression and node.expression.left and
        not node.expression.left.object and not node.expression.left.property and
        node.expression.left.name is @getCovVar())
      throw new Error("Instrumentation error, you cannot redefine the coverage variable in  " + filename + ":" + node.loc.start.line)


  setupCoverage: ->
    coverageInfo.instrumentation = 'blanket'
    coverageInfo.stats =
      suites: 0
      tests: 0
      passes: 0
      pending: 0
      failures: 0
      start: new Date()


  _checkIfSetup: ->
    if not coverageInfo.stats
      throw new Error("You must call blanket.setupCoverage() first.")

  onTestStart: ->
    console.log("BLANKET-Test event started") if @options("debug")
    @_checkIfSetup()
    coverageInfo.stats.tests++
    coverageInfo.stats.pending++

  onTestDone: (total,passed)->
    @_checkIfSetup()
    if passed is total
      coverageInfo.stats.passes++
    else
      coverageInfo.stats.failures++

    coverageInfo.stats.pending--

  onModuleStart: ->
    @_checkIfSetup()
    coverageInfo.stats.suites++

  onTestsDone: ->
    console.log("BLANKET-Test event done") if @options("debug")
    @_checkIfSetup()
    coverageInfo.stats.end = new Date()

    if not @options("branchTracking")
      delete global[@getCovVar()].branchFcn

    @options("reporter").call(this, coverageInfo)


exports.blanket = new Blanket()
