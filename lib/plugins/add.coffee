path     = require 'path'
fs       = require 'fs'
globby   = require 'globby'

module.exports = (punk, reporter) ->
	plugin = {}
	plugin.pipes =
		add: (settings) ->
				settings = [settings] unless Array.isArray settings

				# PIPE #
				(files, cond) ->
					paths = globby.sync settings, cwd: cond.workdir

					if paths.length is 0
						reporter.noFiles settings

					for pth in paths
						contents = fs.readFileSync pth
						files[pth] = contents

					return files

	plugin.pipes.load = plugin.pipes.add

	plugin
