#
#
#
#
#
#

test:
	./node_modules/mocha/bin/mocha --require ./src/index.js test/test-node/testrunner.js
	./node_modules/mocha/bin/mocha --require ./src/index.js --compilers coffee:coffee-script/register test/test-node/testrunner_cs.js

cov:
	./node_modules/mocha/bin/mocha --require ./src/index.js test/test-node/testrunner.js -R html-cov > coverage.html
	open coverage.html


.PHONY: test
