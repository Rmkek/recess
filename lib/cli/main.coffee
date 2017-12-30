do ->
	path    = require 'path'
	fs      = require 'fs-extra'
	program = require 'commander'

	pjPath   = path.resolve(__dirname, '../../package.json')
	pjText   = (await fs.readFile pjPath).toString()
	pj       = JSON.parse pjText

	program
		.version pj.version
		.usage '<task ...>'
		.parse process.argv

	run  = require './run.js'
	init = require '../../index.js'

	pth = path.resolve(__dirname, './evl.js')

	punk = init pth

	# bridge
	dsl =
		use:   -> punk.use   arguments...
		task:  -> punk.task  arguments...
		tasks: -> punk.tasks arguments...
		run:   -> punk.run   arguments...


	code = await fs.readFile(pth)

	run code, dsl
