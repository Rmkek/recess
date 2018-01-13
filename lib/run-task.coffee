gaze   = require 'gaze'
fs     = require 'fs-extra'

module.exports = (recess) ->
	reporter = recess.reporter
	startPipe = (files, task) ->
		# pass files through pipes
		for devnull, pipe of task.pipes
			await files.pipe pipe

		# convert files
		if task.to and not (task.outFile or task.outDir or task.outDirectory)
			await files.pipe recess.p.to(task.to)
			task.outDir = './'
			await files.pipe recess.p.write(task)
		else if task.to
			await files.pipe recess.p.to(task.to)

		if task.min
			await files.pipe recess.p.min()

		await recess.run task.start if task.start and task.start.length > 0

		# write files to FS
		await files.pipe recess.p.write(task)


	recess._runTask = (taskName, task) ->
		reporter.startingTask taskName

		# set settings to standard format
		task = recess.d.toSetting task

		if task.watch
			await return recess._watchTask taskName, task

		files = recess.collection undefined, task

		await recess.run task.needs

		# load files
		await files.pipe recess.p.add(task.entry)

		await startPipe files, task

		# report
		reporter.finishedTask taskName
		await return

	recess._watchTask = (taskName, task) ->
		task ?= recess._tasks[taskName]

		if typeof task is 'function'
			reporter.cantWatch taskName
			await return


		# r._runTask taskName, task
		# set settings to standard format
		task = recess.d.toSetting task

		recess.watchTasks task.needs

		running = false

		recess.dev.keepAlive()
		# load files

		changed = (rg) ->

			files = recess.collection undefined, task

			if rg
				await files.pipe recess.p.add([rg])
			else
				await files.pipe recess.p.add(task.entry)

			await startPipe files, task

			reporter.changed rg if rg
			await return


		gaze task.entry, (err) ->
			throw err if err
			@on 'all', (event, path) -> 
				await recess.d.sleep recess.config.changedDelay
				await changed path

		await return

	recess.watch = (entry, task) ->
		unless task?
			return await recess._watchTask entry[0]

		recess.dev.keepAlive()
		changed = (rg) ->
			files = recess.collection undefined, task
			if rg
				await files.pipe recess.p.add([rg])
			else
				await files.pipe recess.p.add(entry)

			await task.call files

			reporter.changed rg if rg
			await return


		gaze entry, (err) ->
			throw err if err
			@on 'all', (event, path) -> 
				await recess.d.sleep recess.config.changedDelay
				await changed path

		return
