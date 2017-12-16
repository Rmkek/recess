punk = require './index.js'
{ p } = punk

punk.use require 'punker-convert-images'
punk.use require 'punker-uglify'

config = 
	bundle: [
		entry: 'img.svg'
		outFile: 'img.png'
	]
	js: [
		entry: 'lib/dev.js'
		p.minify()
		outFile: 'dev.js'
	]

	# images: [
	# 	entry: 'test/*.svg'
	# 	to: 'png'
	# ]

punk.run config
