path     = require 'path'
fs       = require 'fs-extra'
globby   = require 'globby'

module.exports = (punk) ->
	reporter = punk.reporter
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
					await punk.d.eachAsync paths, (pth) ->
						contents = await fs.readFile(path.resolve cond.workdir, pth)
						files.push ( new punk.File pth, contents )
						await return

					return files

	plugin.pipes.load = plugin.pipes.add

	plugin
