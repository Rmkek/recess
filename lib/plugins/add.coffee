path     = require 'path'
fs       = require 'fs'
globby   = require 'globby'
pn       = require 'pn/fs'

module.exports = (punk, reporter) ->
	plugin = {}
	plugin.pipes =
		add: (settings) ->
				settings = [settings] unless Array.isArray settings

				# PIPE #
				(files, cond) ->
					# get paths
					paths = globby.sync settings, cwd: cond.workdir

					# no files at input
					if paths.length is 0
						reporter.noFiles settings

					# load files
					for pth in paths
						contents = await pn.readFile pth
						files[pth] = contents

					return files

	plugin.pipes.load = plugin.pipes.add

	plugin
