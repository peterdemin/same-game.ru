/*!
 * @description GRUNT! (.js)
 */

module.exports = function (grunt) {
  grunt.initConfig({
    less: {
      development: {
        options: {
          paths: ['less'],
          yuicompress: false
        },
        files: {
          'css/same.css': 'less/same.less',
          'css/slider.css': 'less/slider.less'
        }
      }
    },
    coffee: {
      development: {
        // options: {
        //     paths: ['']
        // }
        files: {
          'js/same.c.js': 'coffee/same.coffee',
          'js/slider.c.js': 'coffee/slider.coffee'
        }
      }
    },
    watch: {
      // scripts: {
      //   files: ['Gruntfile.js', 'public/js/src/**/*.js', 'public/js/vendor/**/*.js'],
      //   tasks: ['jshint', 'concat', 'less'],
      // },
      coffee: {
        files: 'coffee/*.coffee',
        tasks: ['coffee']
      },
      less: {
        files: 'less/*.less',
        tasks: ['less']
      }
    }
  });
  grunt.loadNpmTasks('grunt-contrib-watch');
  // grunt.loadNpmTasks('grunt-contrib-jshint');
  // grunt.loadNpmTasks('grunt-contrib-concat');
  // grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-less');
  // grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-coffee');

  // grunt.registerTask('deploy', ['jshint', 'concat', 'uglify', 'less', 'cssmin']);
  grunt.registerTask('default', ['less', 'coffee', 'watch']);
}
