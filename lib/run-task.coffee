chokidar = require 'chokidar'
pn       = require 'pn/fs'

module.exports = (punk, reporter) ->
	r = 
		_runTask: (taskName, task) ->
			reporter.startingTask taskName

			# set settings to standard format
			task = punk.d.toSetting task

			# load files
			files = await punk.p.add(task.entry)({}, task)

			# pass files through pipes
			for devnull, pipe of task.pipes
				files = await pipe(files, task)

			# convert files
			if task.to
				files = await punk.p.to(task.to)(files, task)

			# write files to FS
			files = await punk.p.write(task)(files, task)

			# report
			reporter.finishedTask taskName
			await return

		_watchTask: (taskName, task) ->
			r._runTask taskName, task
			# set settings to standard format
			task = punk.d.toSetting task

			# load files

			chokidar.watch(task.entry).on 'change', (path) ->
				setTimeout ->
					changed punk.p.add(path)({}, task), path
				, punk.config.changedDelay


			changed = (files, filename) ->
				files ?= await punk.p.add(task.entry)({}, task)

				# pass files through pipes
				for devnull, pipe of task.pipes
					files = await pipe(files, task)

				# convert files
				if task.to
					files = await punk.p.to(task.to)(files, task)

				# write files to FS
				files = await punk.p.write(task)(files, task)

				# report
				reporter.changed filename if filename

			await return
