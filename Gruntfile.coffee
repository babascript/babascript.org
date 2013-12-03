fs = require 'fs'
url = require 'url'
path = require 'path'

PORT = 3000
MODE = 'dist'
INDEX = 'index.html'
index = path.resolve MODE, INDEX

'use strict'

###
npm i grunt \
      grunt-contrib-copy \
      grunt-contrib-coffee \
      grunt-contrib-cssmin \
      grunt-contrib-uglify \
      grunt-contrib-csslint \
      grunt-contrib-stylus \
      grunt-contrib-jade \
      grunt-contrib-imagemin \
      "git+https://github.com/geta6/grunt-coffeelint" \
      "git+https://github.com/gruntjs/grunt-contrib-watch" \
      grunt-simple-mocha
###

module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-csslint'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-imagemin'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-coffeelint'

  grunt.registerTask 'server', [
    'default', 'watch'
  ]

  grunt.registerTask 'client', [
    'copy'
    'coffeelint'
    'coffee'
    'uglify'
    'stylus'
    'csslint'
    'cssmin'
    'jade'
    'imagemin'
    'simplemocha'
  ]

  grunt.registerTask 'default', ['client', 'connect', 'watch']

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    copy:
      img:
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.{jpg,png,gif}' ]
          dest: 'dist/'
        }]
      js:
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.js' ]
          dest: 'dist/'
        }]
      css:
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.css' ]
          dest: 'dist/'
        }]
      source:
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.coffee' ]
          dest: 'dist/'
        }]

    coffee:
      options:
        sourceMap: yes
        sourceRoot: './'
      dist:
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.coffee' ]
          dest: 'dist/'
          ext: '.js'
        }]

    stylus:
      options:
        compress: no
      dist:
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.styl' ]
          dest: 'dist/'
          ext: '.css'
        }]

    jade:
      debug:
        options:
          pretty: yes
          data: version: '<%- pkg.version %>'
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.jade' ]
          dest: 'dist/'
          ext: '.html'
        }]
      dist:
        options:
          data: version: '<%- pkg.version %>'
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.jade' ]
          dest: 'public/'
          ext: '.html'
        }]

    coffeelint:
      options:
        max_line_length:
          value: 79
        indentation:
          value: 2
        newlines_after_classes:
          level: 'error'
        no_empty_param_list:
          level: 'error'
      gruntfile:
        files: [{
          expand: yes
          cwd: './'
          src: [ '*.coffee' ]
        }]
      client:
        files: [{
          expand: yes
          cwd: 'assets/'
          src: [ '**/*.coffee' ]
        }]

    csslint:
      options:
        csslintrc: '.csslintrc'
      strict:
        options:
          import: 2
        src: 'dist/**/*.css'

    uglify:
      dist:
        options:
          mangle: on
        files: [{
          expand: yes
          cwd: 'dist/'
          src: [ '**/*.js' ]
          dest: 'public/'
          ext: '.js'
        }]

    cssmin:
      dist:
        files: [{
          expand: yes
          cwd: 'dist/'
          src: [ '**/*.css' ]
          dest: 'public/'
          ext: '.css'
        }]

    imagemin:
      dist:
        files: [{
          expand: yes
          cwd: 'dist/'
          src: [ '**/*.{jpg,png,gif}' ]
          dest: 'public/'
        }]

    simplemocha:
      options:
        reporter: 'nyan'
        slow: 20
      tests:
        src: [ 'tests/**/*.coffee' ]

    watch:
      options:
        livereload: yes
        interrupt: yes
      gruntfile:
        files: ['Gruntfile.coffee']
        tasks: ['coffeelint:gruntfile']
      client_coffee:
        files: ['assets/**/*.coffee']
        tasks: ['coffeelint:client', 'coffee', 'uglify', 'simplemocha']
      jade:
        files: ['assets/*.jade']
        tasks: ['jade']
      stylus:
        files: ['assets/**/*.styl']
        tasks: ['stylus', 'csslint', 'cssmin']
      image:
        files: ['assets/**/*.{jpg,png,gif}']
        tasks: ['imagemin']

    connect:
      server:
        options:
          port: PORT
          middleware: (connect, options) ->
            mw = [connect.logger 'dev']
            mw.push (req, res) ->
              target = (url.parse req.url).pathname.replace /^\//, ''
              route = path.resolve MODE, target
              fs.exists route, (exist) ->
                fs.stat route, (err, stat) ->
                  if exist and stat.isFile()
                    return fs.createReadStream(route).pipe(res)
                  return fs.createReadStream(index).pipe(res)
            return mw
