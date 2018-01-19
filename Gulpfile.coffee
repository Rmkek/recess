gulp    = require 'gulp'
{ default: uglify }  = require 'gulp-uglify-es'

gulp.task 'min', ->
	gulp.src ['lib/**/*.js']
		.pipe uglify()
		.pipe gulp.dest 'out'

