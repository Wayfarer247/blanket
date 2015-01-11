module.exports = function(grunt) {
  'use strict';
  
  require('load-grunt-tasks')(grunt);
  
  var testConfig = grunt.file.readJSON("test/testconfigs.json");

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.name %> - v<%= pkg.version %> */\n\n',
    cmds: testConfig.cmds,
    runners: testConfig.runners,
    phantom: testConfig.phantom,
    reporters: testConfig.reporters,
    blanketTest: {
      normal:{
        node: "<%= cmds.mocha %> <%= runners.node %>",
        nodeCS: "<%= cmds.mochaCS %> <%= runners.nodeCS %>",
      },
      coverage:{
        node: "<%= cmds.mocha %> --reporter <%= reporters.mocha.node %> <%= runners.node %>",
      }
    },
    concat: {
      esprima: {
        options: {
          banner: '(function(define){\n',
          footer: '\n})(null);<%= "" %>'
        },
        src: ['node_modules/esprima/esprima.js'],
        dest: '.tmp/esprima.js'
      },
      falafel: {
        options: {
          banner: '/*!\n' +
            ' * falafel (c) James Halliday / MIT License\n' +
            ' * https://github.com/substack/node-falafel\n' +
            ' */\n\n' +
            '(function(require,module){\n',
          footer: '\nwindow.falafel = module.exports;})(function(){return {parse: esprima.parse};},{exports: {}});'
        },
        src: ['node_modules/falafel/index.js'],
        dest: '.tmp/falafel.js'
      },
      mocha: {
        options: {
          banner: '<%= banner %>'
        },
        src: [
          '<%= concat.esprima.dest %>',
          '<%= concat.falafel.dest %>',
          'src/blanket.js',
          'src/blanket_browser.js',
          "src/qunit/reporter.js",
          "src/config.js",
          "src/blanketRequire.js",
          "src/adapters/mocha-blanket.js"
        ],
        dest: 'dist/mocha/blanket_mocha.js'
      }
    },
    uglify: {
      options: {
        preserveComments: require('uglify-save-license'),
        beautify: {
          ascii_only: true
        }
      },
      mocha: {
        src: ['dist/mocha/blanket_mocha.js'],
        dest: 'dist/mocha/blanket_mocha.min.js'
      }
    },
    jshint: {
      options: {
        curly: true,
        trailing: true,
        eqeqeq: true,
        immed: false,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: false,
        boss: true,
        strict: false,
        eqnull: true,
        node: true,
        browser: true,
        expr: "warn"
      },
      all: [
        'Gruntfile.js',
        'src/*.js',
        'src/adapters/*.js',
        'tests/*.js',
        'test-node/*.js'
      ]
    },
    clean: {
      tmpfiles: ['./.tmp']
    },
    watch: {
      files: '<%= jshint.all %>',
      tasks: 'default'
    }
  });

  // Load local tasks.
  grunt.loadTasks('tasks');

  grunt.registerTask('build',['jshint', 'concat', 'uglify', 'clean']);
  grunt.registerTask('default', ['build', 'blanketTest']);
  grunt.registerTask('blanket', ['build', 'blanketTest:normal']);
  grunt.registerTask('blanket-coverage', ['build', 'blanketTest:coverage']);
};
