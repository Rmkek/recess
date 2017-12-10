punk = require './index.js'

config = {
		bundle: {
			entry: 'test/main.js'
			pipes: punk.p.bundle()
			outFile: 'main.min.js'
		}
		images: {
			entry: 'test/*.svg'
			to: 'png'
		}
	}

punk.run config
