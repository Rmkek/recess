{ watch } = require 'chokidar'
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


		# write files to FS
		await files.pipe punk.p.write(task)


	punk._runTask = (taskName, task) ->
		reporter.startingTask taskName

		# set settings to standard format
		task = punk.d.toSetting task

		files = new punk.Collection undefined, task

		# load files
		await files.pipe punk.p.add(task.entry)

		await startPipe files, task

		# report
		reporter.finishedTask taskName
		await return

	punk._watchTask = (taskName, task) ->
		# r._runTask taskName, task
		# set settings to standard format
		task = punk.d.toSetting task

		running = false

		# load files

		changed = (rg) ->

			files = new punk.Collection undefined, task

			if rg
				await files.pipe punk.p.add([rg])
			else
				await files.pipe punk.p.add(task.entry)

			await startPipe files, task

			reporter.changed rg if rg
			await return


		notRunning = ->
			setTimeout ->
				running = false
			, punk.config.changedDelay + 10

		sleep = (time) ->
			new Promise (r, j) ->
				setTimeout ->
					r()
				, time

		ch = (event, path) ->
			unless running
				running = true
				await changed path
				notRunning()

		watcher = watch task.entry
		watcher.on 'all',    ch

		await return
