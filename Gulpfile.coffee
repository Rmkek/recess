gulp    = require 'gulp'
css     = require 'gulp-cleancss'
uglify  = require 'gulp-uglify'
html    = require 'gulp-htmlmin'
gulpif  = require 'gulp-if'

gulp.task 'min', ->
	gulp.src ['app/**/*.html', 'app/**/*.js', 'app/**/*.css']
.pipe gulpif 'html', html(collapseWhitespace: true)
.pipe gulpif 'css', css()
.pipe gulpif 'js', uglify()
.pipe gulp.dest 'build'

gulp.task 'default', ['build']
