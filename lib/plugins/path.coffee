path     = require 'path'
relative = require 'relative'

module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		wrap: (settings) =>
				# PIPE #
				recess.i.any (files, cond) ->
					for file in files
						file.path = relative cond.workdir, file.path
						file.path = path.join settings, file.path
					files

		unwrap: (reg, str = "") =>
				# PIPE #
				recess.i.any (files, cond) ->
					xp = new RegExp reg + '/?'
					for file in files
						file.path = file.path.replace xp, str
					files

	plugin
