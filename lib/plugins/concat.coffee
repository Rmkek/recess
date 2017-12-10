module.exports = (punk, reporter) ->
	plugin = {}
	plugin.pipes =
		concat: (settings) ->
			# set settings to standard form
			if typeof settings is 'string'
				settings = { output: settings }

			# PIPE #
			(files) ->

				# no filename
				unless settings.output?
					throw new Error '"concat" needs output file name!'

				# data collector
				arr = []

				# add all files' contents to data collector
				for name, contents of files
					arr.push contents
				
				# new file storage
				r = {}
				# join contents of files
				r[settings.output] = arr.join settings.separator or ''
				return r
	plugin
