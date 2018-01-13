use 'recess-mincss', 'recess-uglify', 'recess-htmlmin'

tasks
	js: [
		entry: ['app/**/*.css', 'app/**/*.js', 'app/**/*.html']
		min
		outDir: 'build'
	]