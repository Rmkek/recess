module.exports = (punk) ->
	reporter = punk.reporter
	punk.run = (settings) ->
		reporter.start()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()
		try

			await punk.d.mapAsync settings, (setting, name) ->
				await punk._runTask name, setting

			reporter.end()
		catch e
			reporter.error e

	punk.watch = (settings) ->
		reporter.startWatch()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()
		try

			await punk.d.mapAsync settings, (setting, name) ->
				await punk._watchTask name, setting

		catch e
			reporter.error e
