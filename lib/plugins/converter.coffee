module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		convert: (settings) ->
			punk.i.buffer (files, cond) ->
				r = await punk.d.mapAsync files, (file) ->
					ext = punk.d.getType file

					# if there's needed converter
					if punk.converters[ext] and punk.converters[ext][settings]

						# get new name
						regexp = new RegExp (ext + '$'), 'i'
						newName = file.path.replace regexp, settings
						
						# find converter
						pipe = punk.converters[ext][settings]

						collection = punk.collection [file], cond
						await collection.pipe pipe

						file = collection.files[0]
						file.path = newName

						# pipe file
						return file
					else if ext is settings
						return file
					else
						# remove file
						reporter.noConverter file.path, settings
						return
				r

	plugin.pipes.to = plugin.pipes.ex = plugin.pipes.convert

	plugin
