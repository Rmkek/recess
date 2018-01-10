path     = require 'path'
fs       = require 'fs-extra'

module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		del: =>
			punk.i.any (files, cond) ->
				for file in files
					pth = path.resolve cond.workdir, file.path
					reporter.log pth

	plugin.pipes.remove = plugin.pipes.del

	plugin
