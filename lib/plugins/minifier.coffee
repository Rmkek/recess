module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		minify: (settings) ->
			recess.i.buffer (files, cond) ->
				r = await recess.d.mapAsync files, (file) ->
					ext = recess.d.getType file

					# if there's needed converter
					if recess.minifiers[ext]

						# find converter
						pipe = recess.minifiers[ext]

						collection = recess.collection [file], cond
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
