use 'punker-uglify', 'punker-convert-images'
ignore defs

tasks
	default: [
		trig: 'images'
	]
	images: [
		entry: 'img.svg'
		outFile: 'bi.svg'
	]
