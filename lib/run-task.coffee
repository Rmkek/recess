watch = require 'glob-watcher'
pn    = require 'pn/fs'

module.exports = (punk, reporter) ->
	r = 
		_runTask: (taskName, task) ->
			reporter.startingTask taskName

			# set settings to standard format
			task = punk.d.toSetting task

			# load files
			files = await punk.p.add(task.entry)([], task)

			# pass files through pipes
			for devnull, pipe of task.pipes
				files = await pipe(files, task)
				punk.d.prepareFiles files

			# convert files
			if task.to
				files = await punk.p.to(task.to)(files, task)

			# write files to FS
			files = await punk.p.write(task)(files, task)

			# report
			reporter.finishedTask taskName
			await return

		_watchTask: (taskName, task) ->
			# r._runTask taskName, task
			# set settings to standard format
			task = punk.d.toSetting task

			# load files

			changed = (rg) ->
				if rg
					files = await punk.p.add([rg])([], task)
				else
					files = await punk.p.add(task.entry)([], task)

				# pass files through pipes
				for devnull, pipe of task.pipes
					files = await pipe(files, task)
					punk.d.prepareFiles files

				# convert files
				if task.to
					files = await punk.p.to(task.to)(files, task)

				# write files to FS
				files = await punk.p.write(task)(files, task)

				reporter.changed rg if rg
				await return

			watcher = watch task.entry

			watcher.on 'add',    (path) -> changed path
			watcher.on 'change', (path) -> changed path

			await return
