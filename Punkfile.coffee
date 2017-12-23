punk = require './index.js'
{ p } = punk

punk.use require 'punker-convert-images'

config =
	images: [
		entry: 'img.svg'
		p.to 'png'
		p.rename 'main.png'
		outDir: 'svgs'
	]


punk.watch config
