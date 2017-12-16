chokidar = require 'chokidar'

module.exports = (punk, reporter) ->
	watch: (settings) ->
		reporter.start()
		reporter.usingConfig punk.filename
		try

			await punk.d.mapAsync settings, (setting, name) ->
				await punk._runTask name, setting

			reporter.end()
		catch e
			reporter.error e
