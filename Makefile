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

blanket:
	./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register ./blanket-tests/*

blanket-cov:
	./node_modules/mocha/bin/mocha --require ./bin/index.js --compilers coffee:coffee-script/register blanket-tests -R html-cov > coverage.html
	open coverage.html

blanket-cov-test:
	./node_modules/mocha/bin/mocha --require ./bin/index.js --compilers coffee:coffee-script/register blanket-tests -R html-cov

compile:
	./node_modules/coffee-script/bin/coffee --output bin --compile src/

.PHONY: test
