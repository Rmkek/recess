gaze   = require 'gaze'
fs     = require 'fs-extra'

module.exports = (punk) ->
	reporter = punk.reporter
	startPipe = (files, task) ->
		# pass files through pipes
		for devnull, pipe of task.pipes
			await files.pipe pipe

		# convert files
		if task.to and not (task.outFile or task.outDir or task.outDirectory)
			await files.pipe punk.p.to(task.to)
			task.outDir = './'
			await files.pipe punk.p.write(task)
		else if task.to
			await files.pipe punk.p.to(task.to)

		if task.min
			await files.pipe punk.p.min()

		await punk.run task.start if task.start and task.start.length > 0

		# write files to FS
		await files.pipe punk.p.write(task)


	punk._runTask = (taskName, task) ->
		reporter.startingTask taskName

		# set settings to standard format
		task = punk.d.toSetting task

		files = punk.collection undefined, task

		await punk.run task.needs

		# load files
		await files.pipe punk.p.add(task.entry)

		await startPipe files, task

		# report
		reporter.finishedTask taskName
		await return

	punk._watchTask = (taskName, task) ->
		task ?= punk._tasks[taskName]

		if typeof task is 'function'
			reporter.cantWatch taskName
			await return


		# r._runTask taskName, task
		# set settings to standard format
		task = punk.d.toSetting task

		punk.watchTasks task.needs

		running = false

		# load files

		changed = (rg) ->

			files = punk.collection undefined, task

			if rg
				await files.pipe punk.p.add([rg])
			else
				await files.pipe punk.p.add(task.entry)

			await startPipe files, task

			reporter.changed rg if rg
			await return


		gaze task.entry, (err) ->
			throw err if err
			@on 'all', (event, path) -> 
				await punk.d.sleep punk.config.changedDelay
				await changed path

		await return

	punk.watch = (entry, task) ->
		unless task?
			return await punk._watchTask entry[0]

		punk.dev.keepAlive()
		changed = (rg) ->
			files = punk.collection undefined, task
			if rg
				await files.pipe punk.p.add([rg])
			else
				await files.pipe punk.p.add(entry)

			await task.call files

			reporter.changed rg if rg
			await return


		gaze entry, (err) ->
			throw err if err
			@on 'all', (event, path) -> 
				await punk.d.sleep punk.config.changedDelay
				await changed path

		return
