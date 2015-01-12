module.exports = function(grunt) {
  'use strict';
  
  require('load-grunt-tasks')(grunt);
  
  var testConfig = grunt.file.readJSON("test/testconfigs.json");

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    cmds: testConfig.cmds,
    runners: testConfig.runners,
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
        'tests/*.js',
        'test-node/*.js'
      ]
    },
    watch: {
      files: '<%= jshint.all %>',
      tasks: 'default'
    }
  });

  // Load local tasks.
  grunt.loadTasks('tasks');

  grunt.registerTask('build',['jshint']);
  grunt.registerTask('default', ['build', 'blanketTest']);
  grunt.registerTask('blanket', ['build', 'blanketTest:normal']);
  grunt.registerTask('blanket-coverage', ['build', 'blanketTest:coverage']);
};
