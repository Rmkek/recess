module.exports = (punk, reporter) ->
	plugin = {}
	plugin.pipes =
		minify: ->
			(files, cond) ->
				r = await punk.d.mapAsync files, (file) ->
					ext = punk.d.getType file

					# if there's needed converter
					if punk.minifiers[ext]

						# find converter
						pipe = punk.minifiers[ext]

						collection = new punk.Collection [file], cond
						await collection.pipe pipe

						# pipe file
						return collection.files[0]
					else
						# remove file
						reporter.noMin file.path, ext
						return
				r


	plugin
