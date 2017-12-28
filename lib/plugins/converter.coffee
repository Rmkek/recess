module.exports = (punk, reporter) ->
	plugin = {}
	plugin.pipes =
		convert: (settings) ->
			(files, cond) ->
				r = await punk.d.mapAsync files, (file) ->
					ext = punk.d.getType file

					# if there's needed converter
					if punk.converters[ext] and punk.converters[ext][settings]

						# get new name
						regexp = new RegExp (ext + '$'), 'i'
						newName = file.path.replace regexp, settings
						
						# find converter
						pipe = punk.converters[ext][settings]

						collection = new punk.Collection [file], cond
						await collection.pipe pipe

						# pipe file
						return collection.files[0]
					else
						# remove file
						reporter.noConverter file.path, ext
						return
				r

	plugin.pipes.to = plugin.pipes.ex = plugin.pipes.convert

	plugin
