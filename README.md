# Blanket Node #

![Build Status](https://travis-ci.org/ethanmick/blanket-node.svg?branch=develop)  
A seamless JavaScript/CoffeeScript code coverage library.

# Why this Fork? #
The original [Blanket](https://github.com/alex-seville/blanket) project has had less and less tending to over the years. Looking at the commit graph, it has a huge amount of work in the beginning, but it slowly tapers off. Bugs have built up, Node has changed, CoffeeScript has changed, and new features should be added.

Also, the work I do is all on CoffeeScript (to each their own), and Blanket had a number of bugs handling CoffeeScript, and things I wish worked better.

Of course, after forking it, I didn't really understand how the project worked... and what better way to find out then dig into the code? And now we are here... where I have re-written the entire project in CoffeeScript.

Whoops!

No worries, it compiles to JS, and that's used in NPM, so you can use this project with JS or CS.

[Original Project Website](http://blanketjs.org/)  

**NOTE: All Pull-Requests must be made into the `develop` branch.**

## Getting Started ##

Installation is pretty straight forwards. I recommend you install it locally, and then use the local version of Mocha to run your tests.

1. Install the package `npm install blanket-node --save-dev`
2. Require Blanket when running tests: `./node_modules/mocha/bin/_mocha --compilers coffee:coffee-script/register --require ./node_modules/blanket-node/bin/index.js -R html-cov > coverage.html ./test`

## Philosophy

Blanket.js is a code coverage tool for javascript that aims to be:

1. Easy to install
2. Easy to use
3. Easy to understand

Blanket.js can be run seamlessly or can be customized for your needs.

## Mechanism

JavaScript code coverage compliments your existing JavaScript tests by adding code coverage statistics (which lines of your source code are covered by your tests).

Blanket works in a 3 step process:

1. Loading your source files
2. Parsing the code using [Esprima](http://esprima.org) and [node-falafel](https://github.com/substack/node-falafel), and instrumenting the file by adding code tracking lines.
3. Connecting to hooks in the test runner to output the coverage details after the tests have completed.

## Roll your own

1. `git clone git@github.com:alex-seville/blanket.git`
2. `npm install`
3. Begin hacking.

## Development

**All development takes place on the `develop` branch**

**Your pull request must pass all tests (run `npm test` to be sure) and respect all existing coverage thresholds**

# Changelog

## Version 2.0.0 (March 12th, 2015)
* No show stopping bugs found
* First release

## Version 2.0.0-beta1 (March 12th, 2015)
* First Beta Release of rewrite

