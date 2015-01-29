test1 = require '../fixture/test/testA'
assert = require 'assert'

describe 'nested test', ->
  it 'should return 7', ->
    assert.equal 7, test1
