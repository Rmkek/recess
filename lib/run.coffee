module.exports = (punk, reporter) ->
	run: (settings) ->
		reporter.start()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()
		try

			await punk.d.mapAsync settings, (setting, name) ->
				await punk._runTask name, setting

			reporter.end()
		catch e
			reporter.error e

	watch: (settings) ->
		reporter.startWatch()
		reporter.usingConfig punk.filename
		punk.d.keepAlive()
		try

			await punk.d.mapAsync settings, (setting, name) ->
				await punk._watchTask name, setting

		catch e
			reporter.error e
