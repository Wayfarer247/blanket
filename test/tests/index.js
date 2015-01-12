var assert = require("assert");
var index = require('../../src/index.js');

describe('index', function(){

  it('should exist', function() {
    assert.ok(index);
    blanket = index();
    assert.ok(blanket);
  });
  
});
