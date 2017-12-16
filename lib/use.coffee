module.exports = (punk, reporter) ->
	_use: (plugin) ->
		plugin = plugin punk, reporter if typeof plugin is 'function'

		if plugin.pipes
			for name, value of plugin.pipes
				if punk.p[name]
					reporter.pluginsConflict(name)
				else
					if Array.isArray value
						value.textInput = true
						punk.p[name] = value[0]
					else
						punk.p[name] = value

		if plugin.converters
			Object.assign punk.converters, plugin.converters

		if plugin.minifiers
			Object.assign punk.minifiers, plugin.minifiers


	use: ->
		if arguments.length > 1
			plugins = arguments
		else if Array.isArray arguments[0]
			plugins = arguments[0]
		else
			plugins = [arguments[0]]

		for name, plugin of plugins
			punk._use plugin