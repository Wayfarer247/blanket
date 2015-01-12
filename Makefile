#
#
#
#
#
#

test:
	./node_modules/mocha/bin/mocha --require ./src/index.js test/testrunner.js
	./node_modules/mocha/bin/mocha --require ./src/index.js --compilers coffee:coffee-script/register test/testrunner_cs.js

travis-cov:
	./node_modules/mocha/bin/mocha --require ./src/index.js test/testrunner.js -R travis-cov

cov:
	./node_modules/mocha/bin/mocha --require ./src/index.js test/testrunner.js -R html-cov > coverage.html
	open coverage.html


.PHONY: test
