should = require('chai').should()
sinon = require 'sinon'
Loader = require '../src/node-loaders/loader'

describe 'Loader', ->

  it 'should exist', ->
    should.exist Loader

  it 'should create a new loader', ->
    loader = new Loader(null, '.js')
    should.exist loader.oldLoader

  it 'should fire when requiring a new file', ->
    fakeBlanket =
      options: -> undefined
      normalizeBackslashes: (->)
      matchPattern: -> no

    spy = sinon.spy fakeBlanket, 'normalizeBackslashes'
    loader = new Loader(fakeBlanket, '.js')
    sinon.stub(loader, 'matchesAntipattern').returns(no)
    sinon.stub(loader, 'oldRead')
    sinon.stub(loader, 'matches').returns(no)

    require './testrunner.js'
    spy.called.should.be.true

  it 'should match the antipattern', ->
    fakeBlanket =
      options: -> './file'
      matchPattern: -> yes

    loader = new Loader(fakeBlanket, '.js')
    filenames = [
      '/Users/username/documents/file/testing.js'
    ]

    result = loader.matchesAntipattern(filenames[0])
    result.should.be.true

  it 'should not find a match if antipattern is not defined', ->
    fakeBlanket =
      options: -> undefined
      matchPattern: -> yes

    loader = new Loader(fakeBlanket, '.js')
    filenames = [
      '/Users/username/documents/file/testing.js'
    ]

    result = loader.matchesAntipattern(filenames[0])
    result.should.be.false

  it 'should match a filter', ->
    fakeBlanket =
      options: -> './filter'
      matchPattern: -> yes

    loader = new Loader(fakeBlanket, '.js')
    filenames = [
      '/Users/username/documents/file/testing.js'
    ]

    result = loader.matches(filenames[0])
    result.should.be.true

  it 'should throw when compiling', ->
    fakeBlanket =
      options: -> './filter'
      matchPattern: -> yes

    loader = new Loader(fakeBlanket, '.js')
    (-> loader.compile()).should.throw /Not Implemented/

  it 'should old read', ->
    fakeBlanket =
      options: -> undefined
      normalizeBackslashes: (->)
      matchPattern: -> no

    loader = new Loader(fakeBlanket, '.js')
    stub = sinon.stub(loader, 'oldLoader')
    loader.oldRead()
    stub.called.should.be.true
