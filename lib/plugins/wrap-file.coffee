module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		header: (settings) ->
			punk.i.buffer (files, cond) ->
				b = Buffer.from settings
				await punk.d.eachAsync files, (file) ->
					file.contents = Buffer.concat [b, file.contents]
				files
		footer: (settings) ->
			punk.i.buffer (files, cond) ->
				b = Buffer.from settings
				await punk.d.eachAsync files, (file) ->
					file.contents = Buffer.concat [file.contents, b]
				files


	plugin
