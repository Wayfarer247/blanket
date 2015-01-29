#
#
#
#
#
#

test:
	./node_modules/mocha/bin/mocha --require ./src/index.coffee --compilers coffee:coffee-script/register test/testrunner.coffee
	./node_modules/mocha/bin/mocha --require ./src/index.coffee --compilers coffee:coffee-script/register test/testrunner_cs.coffee

travis-cov:
	./node_modules/mocha/bin/mocha --require ./src/index.coffee --compilers coffee:coffee-script/register test/testrunner.coffee -R travis-cov

cov:
	./node_modules/mocha/bin/mocha --require ./src/index.coffee --compilers coffee:coffee-script/register test/testrunner.coffee -R html-cov > coverage.html
	open coverage.html


.PHONY: test
