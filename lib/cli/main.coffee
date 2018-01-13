cluster = require 'cluster'
up      = require 'find-up'
gaze    = require 'gaze'

d = (argv) ->
	cwd = process.cwd()
	pth  = await up ['Recess.js', 'recess.js', 'recess', 'Recess'], {cwd}

	time = ->
		dt = new Date

		hours = dt.getHours()
		hoursString = hours + ""
		hoursString = "0" + hoursString if hoursString.length is 1 

		minutes = dt.getMinutes()
		minutesString = minutes + ""
		minutesString = "0" + minutesString if minutesString.length is 1

		seconds = dt.getSeconds()
		secondsString = seconds + ""
		secondsString = "0" + secondsString if secondsString.length is 1 

		"#{hoursString}:#{minutesString}:#{secondsString}"


	notFound = () ->
		console.log "  #{chalk.bold.red time()}   #{chalk.red '»'} #{chalk.bold 'Config not found!'}"

	notFound() unless pth


	# START MASTER
	if cluster.isMaster
		chalk   = require 'chalk'

		worker = cluster.fork()
		onMessage = (msg) ->
			if msg is 'BUILD FINISHED'
				process.exit()
		worker.on 'message', onMessage



		upd = () ->
			console.log()
			console.log "  #{chalk.bold time()}   #{chalk.grey '»'} #{chalk.bold 'Config was changed!'}"
			worker.destroy()
			worker = cluster.fork()
			worker.on 'message', onMessage

		console.log()
		console.log "  #{chalk.bold time()}   #{chalk.grey '»'} #{chalk.bold 'Starting builder...'}"

		gaze pth, (err) ->
			throw err if err

			@on 'delete', ->
				console.log "  #{chalk.bold.red time()}   #{chalk.red '»'} #{chalk.bold 'Config was deleted!'}"

			@on 'changed', (path) -> 
				upd()


		# WATCH CONFIG

	# START CHILD PROCESS FOR KILL IT AFTER :X
	else














		path    = require 'path'
		fs      = require 'fs-extra'
		program = require 'commander'

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

		start = =>
			recess = init pth, cwd

			recess.production = !!program.production

			# bridge
			dsl =
				recess: recess

				use:     recess.use
				uses:    recess.use
				task:    recess.task
				tasks:   recess.task

				spawn:   recess.run
				run: ->
					recess.d.await recess.run arguments...

				watch:   recess.watch
				watches: recess.watch
				ignore:  recess.ignore
				ignores: recess.ignore

				seq:      recess.seq
				sequence: recess.seq
				event:    recess.e
				e:        recess.e

				read: fs.readFileSync

				reporter: recess.reporter
				r:        recess.reporter
				message:  recess.reporter.message
				log:      recess.reporter.message
				err:      recess.reporter.err
				error:    recess.reporter.err
				end:      recess.reporter.end
				warn:     recess.reporter.warn

				console:
					message:  recess.reporter.message
					log:      recess.reporter.message
					info:     recess.reporter.message

					warn:     recess.reporter.warn

					err:      recess.reporter.err
					error:    recess.reporter.err

					info:     recess.reporter.dir

					end:      recess.reporter.end


				production: recess.production
				prod:       recess.production
				p:          recess.production


				outFile: recess.p.outFile
				outDir:  recess.p.outDir


				plugins: recess.plugins
				p:       recess.p
				to:      recess.p.to

				wrap:      recess.p.wrap
				unwrap:    recess.p.unwrap

				del:    recess.p.del
				remove: recess.p.remove

				min:    recess.p.min()
				minify: recess.p.min()

				cluster: recess.p.if()
				pif: recess.p.if()

				stat: recess.p.stat
				add: recess.p.add


				entry:    recess.s.entry
				entries:  recess.s.entry
				input:    recess.s.entry
				inputs:   recess.s.entry
				#
				def:      recess.s.default
				defs:     recess.s.default
				default:  recess.s.default
				defaults: recess.s.default

			code = (await fs.readFile(pth)).toString()


			try
				run code, dsl
			catch e
				recess.r.error e

			ts = program.args

			ts = ['default'] if (ts.length is 0) and (not program.watch) and recess._tasks.default?
			ts = ['default'] if (ts.length is 0) and (    program.watch) and recess._tasks.default?
			ts = ['watch']   if (ts.length is 0) and (    program.watch) and recess._tasks.watch?


			if program.watch
				await recess.startWatch ts
			else
				await recess.startRun ts

		await start()

module.exports = d
