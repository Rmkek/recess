module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		minify: (settings) ->
			punk.i.buffer (files, cond) ->
				r = await punk.d.mapAsync files, (file) ->
					ext = punk.d.getType file

					# if there's needed converter
					if punk.minifiers[ext]

						# find converter
						pipe = punk.minifiers[ext]

						collection = punk.collection [file], cond
						await collection.pipe pipe

						file = collection.files[0]

						# pipe file
						return file
					else
						# remove file
						reporter.noMin file.path
						return
				r

	plugin.pipes.min = plugin.pipes.minify

	plugin
