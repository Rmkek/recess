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
		reporter.start()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()

		ts = [ts] unless Array.isArray ts

		toRun = getToRun ts

		try

			await punk.d.eachAsync toRun, (setting, name) ->
				await punk._runTask name, setting

			reporter.end()
		catch e
			reporter.error e

	punk.watch = (ts) ->
		reporter.startWatch()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()

		ts = [ts] unless Array.isArray ts

		toRun = getToRun ts

		try

			await punk.d.eachAsync toRun, (setting, name) ->
				await punk._watchTask name, setting

		catch e
			reporter.error e
