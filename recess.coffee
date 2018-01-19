use 'recess-uglify'

tasks
	js: [
		entry: ['lib/**/*.js']
		min
		outDir: 'out'
	]