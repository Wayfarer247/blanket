should = require('chai').should()
CoffeeScript = require '../../src/node-loaders/coffee-script'
path = require 'path'

describe 'CoffeeScript Loader', ->

  it 'should exist', ->
    should.exist CoffeeScript

  it 'should make the name short', ->
    filename = "#{__dirname}/coffee-script.coffee"
    console.log filename
    console.log process.cwd()
    filename = filename.replace(process.cwd(),'')
    filename = filename.replace('/', '')
    console.log filename
