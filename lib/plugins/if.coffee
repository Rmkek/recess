mm   = require 'micromatch'

module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		pif: (settings) ->
			punk.i.buffer (files, cond) ->

				await punk.d.eachAsync settings, (pipe, name) ->
					keys = (file.path for file in files)
					filtered = mm keys, name

					for flt in filtered
						file = file for id, file of files when file.path is flt
						collection = punk.collection [file], cond
						await collection.pipe pipe
						file = collection.files[0]
						files[id] = file

				files

	plugin.pipes.if = plugin.pipes.cluster = plugin.pipes.pif


	plugin
