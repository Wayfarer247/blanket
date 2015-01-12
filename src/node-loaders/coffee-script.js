var fs = require("fs"),
    path = require("path");

module.exports = function(blanket){
  var coffeeScript = require("coffee-script");
  var oldLoaderCS = require.extensions['.coffee'];

  require.extensions['.coffee'] = function(localModule, filename) {
    
    var pattern = blanket.options("filter"),
	reporter_options = blanket.options("reporter_options"),
	originalFilename = filename,
	inputFilename = filename;
    filename = blanket.normalizeBackslashes(filename);

    var antipattern = blanket.options("antifilter");
    if (typeof(antipattern) !== "undefined" && blanket.matchPattern(filename.replace(/\.js$/,""), antipattern)) {
      oldLoader(localModule,filename);
      if (blanket.options("debug")) {
	console.log("BLANKET-File will never be instrumented:"+filename);
      }
    } else if (blanket.matchPattern(filename,pattern)){
      if (blanket.options("debug")) {console.log("BLANKET-Attempting instrument of:"+filename);}
      var content = fs.readFileSync(filename, 'utf8');
      if (reporter_options && reporter_options.shortnames){
          inputFilename = filename.replace(path.dirname(filename),"");
      }
      if (reporter_options && reporter_options.basepath){
        inputFilename = filename.replace(reporter_options.basepath + '/',"");
      }
      content = coffeeScript.compile(content);
      blanket.instrument({
        inputFile: content,
        inputFileName: inputFilename
      },function(instrumented){
        var baseDirPath = blanket.normalizeBackslashes(path.dirname(filename))+'/.';
        try{
          instrumented = instrumented.replace(/require\s*\(\s*("|')\./g,'require($1'+baseDirPath);
          localModule._compile(instrumented, originalFilename);
        }
        catch(err){
          console.log("Error parsing instrumented code: "+err);
	  throw new Error("BLANKET-Error parsing instrumented code: "+err);
        }
      });
    }else{
      oldLoaderCS(localModule,originalFilename);
    }
  };
};
