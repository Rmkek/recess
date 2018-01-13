module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		header: (settings) ->
			recess.i.buffer (files, cond) ->
				b = Buffer.from settings
				await recess.d.eachAsync files, (file) ->
					file.contents = Buffer.concat [b, file.contents]
				files
		footer: (settings) ->
			recess.i.buffer (files, cond) ->
				b = Buffer.from settings
				await recess.d.eachAsync files, (file) ->
					file.contents = Buffer.concat [file.contents, b]
				files


	plugin
