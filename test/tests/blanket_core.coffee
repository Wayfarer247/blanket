# core test to lib/blanket.js

assert = require 'assert'
blanketCore = require('../../src/blanket.coffee').blanket
falafel = require 'falafel'
core_fixtures = require '../fixture/core_fixtures'

normalizeWhitespace = (str)->
  str.replace(/\r\n/g, '\n')
    .replace(/\r/g, '\n')
    .replace(/\s+\n/g, '\n')
    .replace(/\n\s+/g, '\n')

assertString = (actual, expected)->
  assert.equal(normalizeWhitespace(actual), normalizeWhitespace(expected))


describe 'tracking', ->

  describe 'tracking setup', ->

    it 'should return tracking setup', ->
      expectedSource = "if (typeof _$jscoverage === 'undefined') _$jscoverage = {};\n"
      expectedSource += "if (typeof _$jscoverage['test.js'] === 'undefined'){_$jscoverage['test.js']=[];\n"
      expectedSource += "_$jscoverage['test.js'].source=['var test=\'1234\';',\n"
      expectedSource += "'//comment',\n"
      expectedSource += "'console.log(test);'];\n"
      expectedSource += "}"
      filename = "test.js"
      sourceArray = [
        "var test='1234';"
        "//comment"
        "console.log(test);"
      ]

      result = blanketCore._trackingSetup(filename, sourceArray)
      assertString(result,expectedSource)

  describe 'source setup', ->

    it 'should return source setup', ->
      source = core_fixtures.simple_test_file_js

      expectedSource= [
        "//this is test source"
        "var test=\\'1234\\';"
        "if (test === \\'1234\\')"
        "  console.log(true);"
        "//comment"
        "console.log(test);"
      ]

      result = blanketCore._prepareSource(source)
      assertString(result.toString(), expectedSource.toString())


  describe 'add tracking', ->

    it 'should add tracking lines', ->
      fname = "simple_test_file.js"
      result = falafel(
        core_fixtures.simple_test_file_js,
        {loc: true, comment: true},
        blanketCore._addTracking(fname), fname )
      assertString(result.toString(), core_fixtures.simple_test_file_instrumented_js)

  describe 'detect single line ifs', ->

    it 'should wrap with block statement', ->
      fname="blockinjection_test_file.js"
      result = falafel(
        core_fixtures.blockinjection_test_file_js,
        {loc: true, comment: true},
        blanketCore._addTracking(fname), fname)
      assertString(result.toString(), core_fixtures.blockinjection_test_file_instrumented_js);


describe 'blanket instrument', ->

  describe 'instrument file', ->
    it 'should return instrumented file', (done)->
      blanketCore.instrument {
        inputFile: core_fixtures.simple_test_file_js,
        inputFileName: "simple_test_file.js"
      }, (result)->
        assertString(result, core_fixtures.simple_test_file_instrumented_full_js)
        done()

  describe 'instrument file with shebang', ->
    it 'should return instrumented file without the shebang', (done)->
      blanketCore.instrument {
        inputFile: core_fixtures.shebang_test_file_js,
        inputFileName: "shebang_test_file.js"
      }, (result)->
        assertString(result, core_fixtures.shebang_test_file_instrumented_js)
        done()


  describe 'instrument tricky if block', ->
    it 'should return properly instrumented string', (done)->
      expected = 4
      infile = "var a=3;if(a==1)a=2;else if(a==3){a="+expected+";}result=a;"
      infilename= "testfile2"

      blanketCore.instrument {
        inputFile: infile,
        inputFileName: infilename
      }, (result)->
        assert.equal(eval("(function test(){"+result+" return result;})()"),expected)
        done()


  describe 'instrument labelled block', ->

    it 'should return properly instrumented string', (done)->
      expected = 9
      infile = "function aFunc(max) {\nvar ret=0; rows: for (var i = 0; i < max--; i++) {\n ret=i; if (i == 9) {\n break rows;\n}\n}\n return ret;}\n "
      infilename= "label_test"

      blanketCore.instrument {
        inputFile: infile,
        inputFileName: infilename
      }, (result)->
        eval(result)
        assert.equal(aFunc(20),expected)
        done()


describe 'test events', ->
  describe 'run through events', ->

    it 'should output correct stats', (done)->
      testReporter = (result)->
        assert.equal(result.instrumentation,"blanket")
        done()

      blanketCore.options("reporter",testReporter)
      blanketCore.setupCoverage()
      blanketCore.onModuleStart()
      blanketCore.onTestStart()
      blanketCore.onTestDone()
      blanketCore.onTestsDone()

describe 'redfinition', ->
  describe 'when coverage variable redined in code', ->
    it 'should output error', ->
      infile = "_$jscoverage=null;"
      infilename= "testfile1"
      assert.throws(
        ->
          blanketCore.instrument {
            inputFile: infile,
            inputFileName: infilename
          }, (result)->
            assert.fail(false,true,"shouldn't get here.")
          /Instrumentation error, you cannot redefine the coverage variable/
      )
