path     = require 'path'
fs       = require 'fs-extra'

module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		del: ->
			recess.i.any (files, cond) ->
				await recess.d.eachAsync files, (file) ->
					pth = path.resolve cond.workdir, file.path
					await fs.remove pth

				files

	plugin.pipes.remove = plugin.pipes.del

	plugin
