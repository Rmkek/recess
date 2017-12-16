module.exports = (punk, reporter) ->
	_runTask: (taskName, task) ->
		reporter.startingTask taskName

		# set settings to standard format
		task = punk.d.toSetting task

		# load files
		files = await punk.p.add(task.entry)({}, task)

		# pass files through pipes
		for devnull, pipe of task.pipes
			files = await pipe(files, task)
			files = punk.d.bufferizeFiles files

		# convert files
		if task.to
			files = await punk.p.to(task.to)(files, task)

		# write files to FS
		files = await punk.p.write(task)(files, task)

		# report
		reporter.finishedTask taskName
		await return
