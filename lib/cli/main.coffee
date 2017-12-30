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

	run  = require './run.js'
	init = require '../../index.js'

	pth  = await up ['Punkfile.js', 'punkfile.js', 'Punkfile', 'punkfile']

	punk = init pth

	# bridge
	dsl =
		punk: punk

		use:     -> punk.use    arguments...
		task:    -> punk.task   arguments...
		tasks:   -> punk.task   arguments...
		run:     -> punk.run    arguments...
		watch:   -> punk.watch  arguments...
		ignore:  -> punk.ignore arguments...
		ignores: -> punk.ignore arguments...

		plugins: punk.plugins
		p:       punk.p
		to:      punk.p.to

		min:    { min: true }
		minify: { min: true }

		entry:    punk.s.entry
		def:      punk.s.default
		defs:     punk.s.default
		default:  punk.s.default
		defaults: punk.s.default


	code = await fs.readFile(pth)

	try
		run code, dsl
	catch e
		punk.r.error e

	ts = program.args

	ts = ['default'] if (ts.length is 0) and (not program.watch) and punk._tasks.default?
	ts = ['default'] if (ts.length is 0) and (    program.watch) and punk._tasks.default?
	ts = ['watch']   if (ts.length is 0) and (    program.watch) and punk._tasks.watch?

	unless program.watch
		punk.startRun ts
	else
		punk.startWatch ts
