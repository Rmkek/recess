module.exports = (punk) ->
	reporter = punk.reporter

	punk._tasks = tasks = {}

	getToRun = (ts) ->
		ret = {}
		for name in ts
			if tasks[name]
				ret[name] = tasks[name]
			else
				reporter.taskNotDefined name 
		ret


	punk.task = punk.tasks = (task) ->
		Object.assign tasks, task

	punk.run = (ts) ->

		funcs = []
		ts.filter (f) ->
			if typeof f is 'function'
				reporter.message 'func'
				funcs.push f
				return false
			else
				return true

		reporter.message funcs

		ts = [ts] unless Array.isArray ts

		toRun = getToRun ts

		try
			await punk.d.eachAsync toRun, (setting, name) ->
				await punk._runTask name, setting
		catch e
			reporter.error e

	punk.watch = (ts) ->
		ts = [ts] unless Array.isArray ts

		toRun = getToRun ts

		try
			await punk.d.eachAsync toRun, (setting, name) ->
				await punk._watchTask name, setting
		catch e
			reporter.error e


	punk.startRun = () ->
		reporter.start()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()		
		await punk.run arguments...
		reporter.end()

	punk.startWatch = () ->
		reporter.startWatch()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()		
		await punk.run arguments...

	punk.seq = punk.sequence = (tasks) ->
		r = () ->
			for task in tasks
				await punk.run task
		r[punk.s.isSequence] = true
		r

