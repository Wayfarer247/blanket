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

* [Getting Started](#getting-started)
* [Philosophy](#philosophy)
* [Mechanism](#mechanism)
* [Grunt Integration](#grunt-integration)
* [Compatibility & Features List](#compatibility-and-features-list)
* [Roll Your Own](#roll-your-own)
* [Development](#development)
* [Contact](#contact)
* [Contributors](#contributors)  
* [Roadmap](#roadmap)
* [Revision History](#revision-history)

## Getting Started ##

Please see the following guides for using Blanket.js:

**Browser**
* [Getting Started](https://github.com/alex-seville/blanket/blob/master/docs/getting_started_browser.md) (Basic QUnit usage)
* [Intermediate](https://github.com/alex-seville/blanket/blob/master/docs/intermediate_browser.md) (Other test runners, global options)
* [Advanced](https://github.com/alex-seville/blanket/blob/master/docs/advanced_browser.md) (writing your own reporters/adapters)
* [Special Features Guide](https://github.com/alex-seville/blanket/blob/master/docs/special_features.md)

**Node**
* [Getting Started](https://github.com/alex-seville/blanket/blob/master/docs/getting_started_node.md) (basic mocha setup)
* [Intermediate](https://github.com/alex-seville/blanket/blob/master/docs/intermediate_node.md) (mocha testrunner, travis-ci reporter)


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

## Grunt Integration

You've got a few options for using Grunt with Blanket:

**grunt-blanket**

A Grunt plugin has been created to allow you to use Blanket like a "traditional" code coverage tool (creating instrumented copies of physical files, as opposed to live-instrumenting).
The plugin runs as a standlone project and can be found [here](https://github.com/alex-seville/grunt-blanket).

**grunt-blanket-qunit**

Runs the QUnit-based Blanket report headlessly using PhantomJS.  Results are displayed on the console, and the task will cause Grunt to fail if any of your configured coverage thresholds are not met. Minimum code coverage thresholds can be configured per-file, per-module, and globally.

See:

* [Plugin Repo](https://github.com/ModelN/grunt-blanket-qunit)
* [Blog Walkthrough](http://www.geekdave.com/2013/07/20/code-coverage-enforcement-for-qunit-using-grunt-and-blanket/)

## Compatibility and Features List

See the [Compatiblity and Feature List](https://github.com/alex-seville/blanket/blob/master/docs/compatibility_and_features.md) including links to working examples.


## Roll your own

1. `git clone git@github.com:alex-seville/blanket.git`
2. `npm install`
3. Begin hacking.

## Development

**All development takes place on the `develop` branch**

**Your pull request must pass all tests (run `npm test` to be sure) and respect all existing coverage thresholds**


## Roadmap

I need to evaluate the code more.

