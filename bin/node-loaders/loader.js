// Generated by CoffeeScript 1.7.1
(function() {
  var Loader, fs;

  fs = require('fs');

  Loader = (function() {
    function Loader(blanket, extension) {
      this.blanket = blanket;
      this.extension = extension;
      if (!this.extension) {
        throw Error('Extension is required!');
      }
      this.oldLoader = require.extensions[this.extension];
      require.extensions[this.extension] = (function(_this) {
        return function(localModule, filename) {
          var inputFilename, originalFilename;
          originalFilename = filename;
          inputFilename = filename;
          filename = _this.blanket.normalizeBackslashes(filename);
          if (_this.matchesAntipattern(filename)) {
            return _this.oldRead(localModule, filename);
          } else if (_this.matches(filename)) {
            return _this.compile(_this.read(filename), filename, function(instrumented) {
              var baseDirPath, err;
              baseDirPath = blanket.normalizeBackslashes(path.dirname(filename)) + '/.';
              try {
                instrumented = instrumented.replace(/require\s*\(\s*("|')\./g, 'require($1' + baseDirPath);
                return localModule._compile(instrumented, originalFilename);
              } catch (_error) {
                err = _error;
                if (_this.blanket.options("ignoreScriptError")) {
                  if (_this.blanket.options("debug")) {
                    console.log("BLANKET-There was an error loading the file:" + filename);
                  }
                  return oldLoader(localModule, filename);
                } else {
                  throw new Error("BLANKET-Error parsing instrumented code: " + err);
                }
              }
            });
          } else {
            return _this.oldRead(localModule, filename);
          }
        };
      })(this);
    }

    Loader.prototype.matchesAntipattern = function(filename) {
      var antipattern, regex;
      antipattern = this.blanket.options('antifilter');
      regex = new RegExp('\\' + this.extension + '$');
      if (typeof antipattern !== 'undefined') {
        return this.blanket.matchPattern(filename.replace(regex, ''), antipattern);
      }
      return false;
    };

    Loader.prototype.matches = function(filename) {
      var pattern;
      pattern = this.blanket.options('filter');
      return this.blanket.matchPattern(filename, pattern);
    };

    Loader.prototype.read = function(filename) {
      var content, inputFilename, reporter_options;
      reporter_options = this.blanket.options('reporter_options');
      content = fs.readFileSync(filename, 'utf8');
      if (reporter_options && reporter_options.shortnames) {
        inputFilename = filename.replace(path.dirname(filename), "");
      }
      if (reporter_options && reporter_options.basepath) {
        inputFilename = filename.replace(reporter_options.basepath + '/', "");
      }
      return {
        contents: content,
        filename: inputFilename
      };
    };

    Loader.prototype.oldRead = function(localModule, filename) {
      return this.oldLoader(localModule, filename);
    };

    Loader.prototype.compile = function(contents, filename, next) {
      throw new Error('Not Implemented!');
    };

    return Loader;

  })();

  module.exports = Loader;

}).call(this);
