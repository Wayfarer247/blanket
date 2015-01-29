assert = require 'assert'
index = require '../../src/index.coffee'

describe 'index', ->

  it 'should exist', ->
    assert.ok index
    blanket = index()
    assert.ok blanket
