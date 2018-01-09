module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		convert: (settings) ->
			if typeof settings not in ['number', 'string']
				reporter.error 'Setting must be a number or string!'


			punk.i.buffer (files, cond) ->
				r = await punk.d.mapAsync files, (file) ->
					ext = punk.d.getType file

					# if there's needed converter
					if punk.converters[ext] and punk.converters[ext][settings]

						pipe = punk.converters[ext][settings]

						collection = punk.collection [file], cond
						await collection.pipe pipe

						file = collection.files[0]
						file.setExt settings

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
