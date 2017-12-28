watch = require 'glob-watcher'

module.exports = (punk, reporter) ->
	r = 
		_runTask: (taskName, task) ->
			reporter.startingTask taskName

			# set settings to standard format
			task = punk.d.toSetting task

			files = new punk.Collection undefined, task

			# load files
			await files.pipe punk.p.add(task.entry)

			# pass files through pipes
			for devnull, pipe of task.pipes
				await files.pipe pipe

			# convert files
			if task.to and 
			not (task.outFile or task.outDir or task.outDirectory)
				await files.pipe punk.p.to(task.to)
				task.outDir = './'
				await files.pipe punk.p.write(task)
				reporter.message 'ssdsdsds'
			else if task.to
				await files.pipe punk.p.to(task.to)

			# write files to FS
			await files.pipe punk.p.write(task)

			# report
			reporter.finishedTask taskName
			await return

		_watchTask: (taskName, task) ->
			# r._runTask taskName, task
			# set settings to standard format
			task = punk.d.toSetting task

			# load files

			changed = (rg) ->

				files = new punk.Collection undefined, task

				if rg
					await files.pipe punk.p.add([rg])
				else
					await files.pipe punk.p.add(task.entry)

				# pass files through pipes
				for devnull, pipe of task.pipes
					await files.pipe pipe

				# convert files
				if task.to
					await files.pipe punk.p.to(task.to)

				# write files to FS
				p = files.pipe(punk.p.write(task))
				reporter.message p.pipe
				# p.pipe punk.p.write(task)

				reporter.changed rg if rg
				await return

			watcher = watch task.entry

			ch = (path) ->
				setTimeout ->
					changed path
				, punk.config.changedDelay

			watcher.on 'add',    ch
			watcher.on 'change', ch

			await return
