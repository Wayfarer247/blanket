// Generated by CoffeeScript 1.8.0
(function() {
  var args, blanketNode, blanketRequired, configPath, extend, file, fs, i, join, packageConfigs, path, val, _i, _j, _len, _len1;

  extend = require('xtend');

  path = require('path');

  join = path.join;

  fs = require('fs');

  configPath = join(process.cwd(), 'package.json');

  file = fs.existsSync(configPath) ? JSON.parse(fs.readFileSync(configPath) || {}) : null;

  packageConfigs = null;

  blanketNode = function(userOptions) {
    var blanket, blanketConfigs, config, escapeRegExp, newLoader, newOptions, oldLoader, pattern, scripts;
    if (file) {
      scripts = file.scripts;
      config = file.config;
      if (config && config.blanket) {
        packageConfigs = config.blanket;
      }
    }
    blanketConfigs = packageConfigs ? extend(packageConfigs, userOptions) : userOptions;
    pattern = blanketConfigs ? blanketConfigs.pattern : "src";
    blanket = require('./blanket').blanket;
    oldLoader = require.extensions['.js'];
    newLoader = null;
    escapeRegExp = function(str) {
      return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
    };
    if (blanketConfigs) {
      newOptions = {};
      Object.keys(blanketConfigs).forEach(function(option) {
        var optionValue;
        optionValue = blanketConfigs[option];
        if (option === 'data-cover-only' || option === 'pattern') {
          newOptions.filter = optionValue;
        }
        if (option === 'data-cover-never') {
          newOptions.antifilter = optionValue;
        }
        if (option === 'data-cover-loader' || option === 'loader') {
          newOptions.loader = optionValue;
        }
        if (option === 'data-cover-timeout') {
          newOptions.timeout = optionValue;
        }
        if (option === 'onlyCwd' && !!optionValue) {
          newOptions.cwdRegex = new RegExp("^" + escapeRegExp(process.cwd()), "i");
        }
        if (option === 'data-cover-customVariable') {
          newOptions.customVariable = optionValue;
        }
        if (option === 'data-cover-flags') {
          newOptions.order = !optionValue.unordered;
          newOptions.ignoreScriptError = !!optionValue.ignoreError;
          newOptions.autoStart = !!optionValue.autoStart;
          newOptions.branchTracking = !!optionValue.branchTracking;
          newOptions.debug = !!optionValue.debug;
          newOptions.engineOnly = !!optionValue.engineOnly;
        }
        if (option === 'data-cover-reporter-options') {
          return newOptions.reporter_options = optionValue;
        }
      });
      blanket.options(newOptions);
    }
    blanket.restoreNormalLoader = function() {
      if (!blanket.options('engineOnly')) {
        newLoader = require.extensions['.js'];
        return require.extensions['.js'] = oldLoader;
      }
    };
    blanket.restoreBlanketLoader = function() {
      if (!blanket.options('engineOnly')) {
        return require.extensions['.js'] = newLoader;
      }
    };
    if (!blanket.options('engineOnly')) {

      /*
      { id: '/Users/ethan/Documents/blanket/test/fixture/test/testA.js',
      exports: {},
      parent:
       { id: '/Users/ethan/Documents/blanket/test/tests/nested_test.js',
         exports: {},
         parent:
          { id: '/Users/ethan/Documents/blanket/test/testrunner.js',
            exports: {},
            parent: [Object],
            filename: '/Users/ethan/Documents/blanket/test/testrunner.js',
            loaded: false,
            children: [Object],
            paths: [Object] },
         filename: '/Users/ethan/Documents/blanket/test/tests/nested_test.js',
         loaded: false,
         children: [ [Circular] ],
         paths:
          [ '/Users/ethan/Documents/blanket/test/tests/node_modules',
            '/Users/ethan/Documents/blanket/test/node_modules',
            '/Users/ethan/Documents/blanket/node_modules',
            '/Users/ethan/Documents/node_modules',
            '/Users/ethan/node_modules',
            '/Users/node_modules',
            '/node_modules' ] },
      filename: '/Users/ethan/Documents/blanket/test/fixture/test/testA.js',
      loaded: false,
      children: [],
      paths:
       [ '/Users/ethan/Documents/blanket/test/fixture/test/node_modules',
         '/Users/ethan/Documents/blanket/test/fixture/node_modules',
         '/Users/ethan/Documents/blanket/test/node_modules',
         '/Users/ethan/Documents/blanket/node_modules',
         '/Users/ethan/Documents/node_modules',
         '/Users/ethan/node_modules',
         '/Users/node_modules',
         '/node_modules' ] }
       */

      /*
      This needs to be refactored out
       */
      require.extensions['.js'] = function(localModule, filename) {
        var antipattern, content, inputFilename, originalFilename, reporter_options;
        pattern = blanket.options('filter');
        reporter_options = blanket.options('reporter_options');
        originalFilename = filename;
        inputFilename = filename;
        filename = blanket.normalizeBackslashes(filename);
        antipattern = blanket.options('antifilter');
        if (typeof antipattern !== 'undefined' && blanket.matchPattern(filename.replace(/\.js$/, ""), antipattern)) {
          oldLoader(localModule, filename);
          if (blanket.options("debug")) {
            return console.log("BLANKET-File will never be instrumented:" + filename);
          }
        } else if (blanket.matchPattern(filename, pattern)) {
          if (blanket.options("debug")) {
            console.log("BLANKET-Attempting instrument of:" + filename);
          }
          content = fs.readFileSync(filename, 'utf8');
          if (reporter_options && reporter_options.shortnames) {
            inputFilename = filename.replace(path.dirname(filename), "");
          }
          if (reporter_options && reporter_options.basepath) {
            inputFilename = filename.replace(reporter_options.basepath + '/', "");
          }
          return blanket.instrument({
            inputFile: content,
            inputFileName: inputFilename
          }, function(instrumented) {
            var baseDirPath, err;
            baseDirPath = blanket.normalizeBackslashes(path.dirname(filename)) + '/.';
            try {
              instrumented = instrumented.replace(/require\s*\(\s*("|')\./g, 'require($1' + baseDirPath);
              return localModule._compile(instrumented, originalFilename);
            } catch (_error) {
              err = _error;
              if (blanket.options("ignoreScriptError")) {
                if (blanket.options("debug")) {
                  console.log("BLANKET-There was an error loading the file:" + filename);
                }
                return oldLoader(localModule, filename);
              } else {
                throw new Error("BLANKET-Error parsing instrumented code: " + err);
              }
            }
          });
        } else {
          return oldLoader(localModule, originalFilename);
        }
      };
    }
    if (blanket.options("loader")) {
      require(blanket.options("loader"))(blanket);
    }
    newLoader = require.extensions['.js'];
    return blanket;
  };

  if (process.env.BLANKET_COV) {
    module.exports = blanketNode({
      engineOnly: true
    });
  } else {
    args = process.argv;
    blanketRequired = false;
    for (i = _i = 0, _len = args.length; _i < _len; i = ++_i) {
      val = args[i];
      if (['-r', '--require'].indexOf(val) > -1 && args[i + 1] === 'blanket') {
        blanketRequired = true;
      }
    }
    for (i = _j = 0, _len1 = args.length; _j < _len1; i = ++_j) {
      val = args[i];
      if (['-r', '--require'].indexOf(val) > -1 && args[i + 1].indexOf('bin/index.js') > -1) {
        blanketRequired = true;
      }
    }
    if (args[0] === 'node' && args[1].indexOf(join('node_modules', 'mocha', 'bin')) > -1 && blanketRequired) {
      module.exports = blanketNode(null);
    } else {
      module.exports = function(options) {
        return blanketNode(options);
      };
    }
  }

}).call(this);