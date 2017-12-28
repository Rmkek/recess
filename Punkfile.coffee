punk = require './index.js'
{ p } = punk

punk.use require('punker-uglify'), require('punker-convert-images')

config =
	images: [
		entry: 'img.svg'
		to: 'png'
	]

punk.run config
