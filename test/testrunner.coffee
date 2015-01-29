path = require 'path'
blanket = require('../src/index')({
  pattern: ['/src/blanket', '/src/index']
})

###
since we're using blanket to test blanket,
we need to remove the module entry from the require cache
so that it can be instrumented.
###
delete require.cache[path.normalize(__dirname + '/../src/blanket.js')]
delete require.cache[path.normalize(__dirname + '/../src/index.js')]

###
now start the tests
###
require('./tests/blanket_core')
require('./tests/index')
require('./tests/nested_test')
require('./tests/instrumentation_test')
