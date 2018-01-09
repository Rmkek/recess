uses 'punker-uglify'

tasks
	js: [
		needs: 'min'
	]

	min: [
		entry: 'Punkfile.js'
		min
		outFile: '2.js'
	]
