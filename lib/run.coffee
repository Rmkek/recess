uuid = require 'uuid/v1'
mm   = require 'micromatch'

module.exports = (punk) ->
	reporter = punk.reporter

	punk._tasks = tasks = {}

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


	punk.task = punk.tasks = (task) ->
		Object.assign tasks, task

	punk.run = (ts) ->
		ts = [ts] unless Array.isArray ts
		toRun = getToRun ts
		try
			await punk.d.eachAsync toRun, (setting, name) ->
				if typeof setting is 'function'
					cont = punk.collection []
					await (setting.call cont)
				else
					await punk._runTask name, setting
		catch e
			reporter.error e

	punk.startRun = () ->
		reporter.start()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()		
		await punk.run arguments...
		reporter.end() unless punk.alive

	punk.startWatch = () ->
		reporter.startWatch()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()		
		await punk.watch arguments...

	punk.seq = punk.sequence = ->
		tsks = punk.d.flat arguments
		r = () ->
			for task in tsks
				await punk.run task
		r[punk.s.isSequence] = true
		r

	punk.e = punk.event = (f) ->
		r = -> f()
		r[punk.s.isEvent] = true
		r
