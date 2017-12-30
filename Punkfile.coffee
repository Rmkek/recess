use 'punker-uglify', 'punker-convert-images'

tasks
	default: [
		entry: 'lib/cli/main.js'
		p.header '#!/usr/bin/env node\n'
		outFile: entry
	]
