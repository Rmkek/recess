module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		concat: (settings, separator) ->
			# set settings to standard form
			if separator? and typeof settings isnt 'object'
				settings = { output: settings, separator: separator }
			else if typeof settings isnt 'object'
				settings = { output: settings, separator: '' }
			else
				reporter.error new Error 'Settings not defined!' 

			# PIPE #
			recess.i.buffer (files) ->

				separator = Buffer.from settings.separator

				# buffer concat list
				joinList = []

				for file in files
					joinList.push file.contents, separator
				joinList.pop()

				out = Buffer.concat joinList

				# new file storage
				r = []
				r.push new recess.File( settings.output, out )

				return r

	plugin.pipes.rename = plugin.pipes.concat

	plugin
