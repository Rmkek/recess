punk = require './index.js'
{ p } = punk

punk.use 'punker-uglify', 'punker-convert-images'

config =
	images: [
		entry: 'img.svg'
		to: 'png'
	]

punk.run config
