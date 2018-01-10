assign = require 'deep-assign'
Mode   = require 'stat-mode'

normalize = (mode) ->
	called = false
	newMode = 
		owner: {}
		group: {}
		others: {}
	for key in ['read', 'write', 'execute'] when typeof mode[key] == 'boolean'
		newMode.owner[key] = mode[key]
		newMode.group[key] = mode[key]
		newMode.others[key] = mode[key]
		called = true

	if called then newMode else mode

module.exports = (punk) ->
	reporter = punk.reporter
	plugin = {}
	plugin.pipes =
		stat: (stat) ->
			if typeof stat is 'object'
				stat = normalize stat

			punk.i.any (files, cond) ->
				for file in files

					if typeof stat is 'number'
						file.stat = stat
					else	
						assign file.stat, stat
				files

	plugin.pipes.mode = plugin.pipes.stat

	plugin
