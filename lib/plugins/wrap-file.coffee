module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		header: (settings) ->
			(files, cond) ->
				b = Buffer.from settings
				await punk.d.eachAsync files, (file) ->
					file.contents = Buffer.concat [b, file.contents]

	plugin
