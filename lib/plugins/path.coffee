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

		unwrap: (reg, str = "") =>
				# PIPE #
				punk.i.any (files, cond) ->
					xp = new RegExp reg + '/?'
					for file in files
						file.path = file.path.replace xp, str
					files

	plugin
