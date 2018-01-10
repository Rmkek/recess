module.exports = (argv) ->
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
		.option '-p, --production', 'Production mode'
		.parse argv

	run  = require './run.js'
	init = require '../../index.js'

	cwd = process.cwd()
	pth  = await up ['Punkfile.js', 'punkfile.js', 'Punkfile', 'punkfile'], {cwd}

	punk = init pth, cwd

	punk.production = !!program.production

	# bridge
	dsl =
		punk: punk

		use:     punk.use
		uses:    punk.use
		task:    punk.task
		tasks:   punk.task

		spawn:   punk.run
		run: ->
			punk.d.await punk.run arguments...

		watch:   punk.watch
		watches: punk.watch
		ignore:  punk.ignore
		ignores: punk.ignore

		seq:      punk.seq
		sequence: punk.seq
		event:    punk.e
		e:        punk.e

		read: fs.readFileSync

		reporter: punk.reporter
		r:        punk.reporter
		message:  punk.reporter.message
		log:      punk.reporter.message
		err:      punk.reporter.err
		error:    punk.reporter.err
		end:      punk.reporter.end
		warn:     punk.reporter.warn

		console:
			message:  punk.reporter.message
			log:      punk.reporter.message
			info:     punk.reporter.message

			warn:     punk.reporter.warn

			err:      punk.reporter.err
			error:    punk.reporter.err

			info:     punk.reporter.dir

			end:      punk.reporter.end


		production: punk.production
		prod:       punk.production
		p:          punk.production


		outFile: punk.p.outFile
		outDir:  punk.p.outDir


		plugins: punk.plugins
		p:       punk.p
		to:      punk.p.to

		min:    punk.p.min()
		minify: punk.p.min()

		cluster: punk.p.if()
		pif: punk.p.if()

		stat: punk.p.stat
		add: punk.p.add


		entry:    punk.s.entry
		entries:  punk.s.entry
		input:    punk.s.entry
		inputs:   punk.s.entry
		#
		def:      punk.s.default
		defs:     punk.s.default
		default:  punk.s.default
		defaults: punk.s.default

	code = (await fs.readFile(pth)).toString()


	try
		run code, dsl
	catch e
		punk.r.error e

	ts = program.args

	ts = ['default'] if (ts.length is 0) and (not program.watch) and punk._tasks.default?
	ts = ['default'] if (ts.length is 0) and (    program.watch) and punk._tasks.default?
	ts = ['watch']   if (ts.length is 0) and (    program.watch) and punk._tasks.watch?


	if program.watch
		punk.startWatch ts
	else
		punk.startRun ts
