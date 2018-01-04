path = require 'path'

do ->
	main = path.resolve __dirname, '../lib/cli/main.js'
	punk = require main
	await punk process.argv
