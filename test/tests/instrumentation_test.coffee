core_fixtures = require '../fixture/core_fixtures'
assert = require 'assert'
blanketCore = require('../../src/blanket').blanket

describe 'when instrumenting a file', ->

  it 'should instrument comments correctly', (done)->
    blanketCore.instrument
      inputFile: core_fixtures.comment_test_file_js
      inputFileName: "comment_test_file"
    , (result)->
      assert.equal(core_fixtures.comment_test_file_instrumented_js,result)
      done()

  it 'should instrument branches correctly', (done)->
    blanketCore.options("branchTracking", true)
    blanketCore.instrument
      inputFile: core_fixtures.branch_test_file_js
      inputFileName: "branch_test_file"
    , (result)->
      assert.equal(core_fixtures.branch_test_file_instrumented_js,result)
      blanketCore.options("branchTracking",false)
      done()

  it 'should instrument complex branches correctly', (done)->
    blanketCore.options("branchTracking",true)
    blanketCore.instrument
      inputFile: core_fixtures.branch_complex_test_file_js
      inputFileName: "branch_complex_test_file"
    , (result)->
      assert.equal(core_fixtures.branch_complex_test_file_instrumented_js,result)
      blanketCore.options("branchTracking",false)
      done()

  it 'should instrument multi-line branches correctly', (done)->
    blanketCore.options("branchTracking",true)
    blanketCore.instrument
      inputFile: core_fixtures.branch_multi_line_test_file_js
      inputFileName: "multi_line_branch_test_file"
    , (result)->
      assert.equal(core_fixtures.branch_multi_line_test_file_instrumented_js,result)
      blanketCore.options("branchTracking",false)
      done()


describe 'when a file is instrumented', ->
  describe 'if we run the code', ->
    it 'should output correct stats', (done)->
      blanketCore.options("branchTracking",true)
      blanketCore.instrument
        inputFile: core_fixtures.branch_test_file_js
        inputFileName: "branch_test_file2"
      , (result)->
        eval(result)
        BRANCHTEST(0)
        fileResults = global._$jscoverage["branch_test_file2"]
        branchResults = fileResults.branchData[2][7]

        assert.equal(branchResults.length > 0,true)
        bothHit = (
          typeof branchResults[0] isnt 'undefined' and branchResults[0].length > 0 and
            typeof branchResults[1] isnt 'undefined' and branchResults[1].length > 0
        )
        assert.equal(bothHit,false,"both are not hit.")
        BRANCHTEST(1)
        bothHit = (
          typeof branchResults[0] isnt 'undefined' and branchResults[0].length > 0 and
            typeof branchResults[1] isnt 'undefined' and branchResults[1].length > 0
        )
        assert.equal(bothHit,true,"both are  hit.")
        blanketCore.options("branchTracking",false)

        done()

    it 'should output correct stats. even if more complex', (done)->
      blanketCore.options("branchTracking",true)
      blanketCore.instrument
        inputFile: core_fixtures.branch_complex_test_file_js
        inputFileName: "branch_test_file3"
      , (result)->
        eval(result)

        COMPLEXBRANCHTEST(1,0,0)

        COMPLEXBRANCHTEST(0,0,0)

        COMPLEXBRANCHTEST(0,2,0)

        COMPLEXBRANCHTEST(0,2,3)

        fileResults = global._$jscoverage["branch_test_file3"]

        branchResults = fileResults.branchData[2][7]
        assert.equal(branchResults.length > 0,true)
        bothHit = (
          typeof branchResults[0] isnt 'undefined' and branchResults[0].length > 0 and
            typeof branchResults[1] isnt 'undefined' and branchResults[1].length > 0
        )

        branchResults = fileResults.branchData[2][24]
        assert.equal(branchResults.length > 0,true)
        bothHit = bothHit and (
          typeof branchResults[0] isnt 'undefined' and branchResults[0].length > 0 and
            typeof branchResults[1] isnt 'undefined' and branchResults[1].length > 0
        )

        branchResults = fileResults.branchData[2][34]
        assert.equal(branchResults.length > 0,true)
        bothHit = bothHit and (
          typeof branchResults[0] isnt 'undefined' and branchResults[0].length > 0 and
            typeof branchResults[1] isnt 'undefined' and branchResults[1].length > 0
        )
        assert.equal(bothHit,true,"all are hit.")
        blanketCore.options("branchTracking",false)

        done()
