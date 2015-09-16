module.exports = function(grunt) {
 
 
  grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    jshint: {
      all: ['Gruntfile.js',
        'app/js/*.js',
        'app/js/libs/*.js',
        'app/tests/*.js'
      ],
      options: {
        ignores: [
        ],

        // relax errors/warnings
        sub: true // ['property'] is better written in dot notation.
      }
    },
 
    watch :{
      scripts :{
        files : ['app/js/*.js','app/css/*.css','index.html', 'app/js/templates/*'],
        options : {
          livereload : 9099,
        }
      }
    }
  });
 
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-jshint');

  grunt.registerTask('default', ['jshint']);
};

