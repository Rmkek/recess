do ->
	path    = require 'path'
	fs      = require 'fs-extra'
	program = require 'commander'
	up      = require 'find-up'

	pjPath   = path.resolve(__dirname, '../../package.json')
	pjText   = (await fs.readFile pjPath).toString()
	pj       = JSON.parse pjText

	program
		.version pj.version
		.usage '[options] <task ...>'
		.option '-w, --watch', 'Look after files'
		.parse process.argv

	console.log program.watch, program.args

	run  = require './run.js'
	init = require '../../index.js'

	pth  = await up ['Punkfile.js', 'punkfile.js', 'Punkfile', 'punkfile']

	punk = init pth

	# bridge
	dsl =
		use:   -> punk.use   arguments...
		task:  -> punk.task  arguments...
		tasks: -> punk.tasks arguments...
		run:   -> punk.run   arguments...
		watch: -> punk.watch arguments...

		plugins: punk.plugins
		p:       punk.p
		to:      punk.p.to

		min:    { min: true }
		minify: { min: true }

		entry:   punk.s.entry


	code = await fs.readFile(pth)

	run code, dsl

	ts = program.args

	if (ts.length is 0) and (not program.watch) and punk._tasks.default?
		ts = ['default']

	if (ts.length is 0) and (program.watch) and punk._tasks.default?
		ts = ['default']

	if (ts.length is 0) and (program.watch) and punk._tasks.watch?
		ts = ['watch']

	unless program.watch
		dsl.run   ts
	else
		dsl.watch ts
