punk = require './index.js'
{ p } = punk

punk.use require 'punker-convert-images'
punk.use require 'punker-uglify'

config = 
	images: [
		entry: 'img.svg'
		outFile: 'img.png'
	]
	js: [
		entry: 'lib/dev.js'
		outFile: 'dev.js'
	]

punk.watch config
