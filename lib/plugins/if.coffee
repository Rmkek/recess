mm   = require 'micromatch'

module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		pif: (settings) ->
			recess.i.any (files, cond) ->

				await recess.d.eachAsync settings, (pipe, name) ->
					keys = (file.path for file in files)
					filtered = mm keys, name

					for flt in filtered
						file = file for id, file of files when file.path is flt
						collection = recess.collection [file], cond
						await collection.pipe pipe
						file = collection.files[0]
						files[id] = file

				files

	plugin.pipes.if = plugin.pipes.cluster = plugin.pipes.switch = plugin.pipes.pif


	plugin
