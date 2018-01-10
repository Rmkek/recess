path     = require 'path'
relative = require 'relative'

module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		wrap: (settings) =>
				# PIPE #
				punk.i.any (files, cond) ->
					for file in files
						file.path = relative cond.workdir, file.path
						file.path = path.join settings, file.path
					files

		unwrap: (settings = 1) =>
				# PIPE #
				punk.i.any (files, cond) ->
					for file in files
						file.path = file.path.split path.sep
						for devnull in [0..settings]
							file.path.shift()
						file.path = file.path.join '/'
					files

	plugin
