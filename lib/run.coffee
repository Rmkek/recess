uuid = require 'uuid/v1'
mm   = require 'micromatch'

module.exports = (recess) ->
	reporter = recess.reporter

	recess._tasks = tasks = {}

	getToRun = (ts) ->
		ret = {}
		for name in ts
			if typeof name is 'function'
				ret[uuid()] = name
				continue

			else if typeof name is 'string'
				keys = mm(Object.keys(tasks), [name])
				ret[key] = tasks[key] for key in keys

				reporter.tasksNotFound ts if keys.length is 0
		ret


	recess.task = recess.tasks = (task) ->
		Object.assign tasks, task

	recess.run = (ts) ->
		ts = [ts] unless Array.isArray ts
		toRun = getToRun ts
		try
			await recess.d.eachAsync toRun, (setting, name) ->
				if typeof setting is 'function'
					cont = recess.collection []

					try

						if !~recess._services.indexOf setting
							reporter.startingTask name

							await (setting.call cont)

							recess._services.push setting

							reporter.finishedTask name

					catch e
						reporter.error e
					
				else
					await recess._runTask name, setting
		catch e
			reporter.error e

	recess.watchTasks = (ts) ->
		ts = [ts] unless Array.isArray ts
		toRun = getToRun ts
		try
			await recess.d.eachAsync toRun, (setting, name) ->
				if typeof setting is 'function'
					reporter.cantWatch name
				else
					await recess._watchTask name, setting
		catch e
			reporter.error e

	recess.startRun = () ->
		reporter.start()
		reporter.usingConfig recess.filename
		await recess.run arguments...
		reporter.end() unless recess.alive

	recess.startWatch = () ->
		reporter.startWatch()
		reporter.usingConfig recess.filename
		recess.d.keepAlive()		
		await recess.watch arguments...

	recess.seq = recess.sequence = ->
		tsks = recess.d.flat arguments
		r = () ->
			for task in tsks
				await recess.run task
		r[recess.s.isSequence] = true
		r

	recess.e = recess.event = (f) ->
		r = -> f()
		r[recess.s.isEvent] = true
		r
