resolve = require 'resolve'

module.exports = (punk) ->
	reporter = punk.reporter
	punk._use = (plugin) ->
		return if plugin is undefined
		reporter.pluginNotFound() unless plugin

		# get plugin from string
		if typeof plugin in ['string', 'number']

			try pth = resolve.sync plugin, { basedir: punk.dirname }

			reporter.pluginNotFound(plugin) unless pth?
			plugin = require pth

		plugin = plugin punk, reporter if typeof plugin is 'function'

		# merge

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


	punk.use = ->
		if arguments.length > 1
			plugins = arguments
		else if Array.isArray arguments[0]
			plugins = arguments[0]
		else
			plugins = [arguments[0]]

		for name, plugin of plugins
			punk._use plugin