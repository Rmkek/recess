resolve = require 'resolve'

module.exports = (recess) ->
	reporter = recess.reporter
	recess._use = (plugin) ->
		return if plugin is undefined
		reporter.pluginNotFound() unless plugin

		# get plugin from string
		if typeof plugin in ['string', 'number']
			try pth = resolve.sync plugin, { basedir: recess.dirname }

			reporter.pluginNotFound(plugin) unless pth?
			plugin = require pth

		plugin = plugin recess, reporter if typeof plugin is 'function'

		# merge

		if plugin.pipes
			for name, value of plugin.pipes
				if recess.p[name]
					reporter.pluginsConflict(name)
				else
					recess.p[name] = value

		if plugin.converters
			Object.assign recess.converters, plugin.converters

		if plugin.minifiers
			Object.assign recess.minifiers, plugin.minifiers

		if plugin.tasks
			Object.assign recess.fastTasks, plugin.tasks


	recess.use = ->
		if arguments.length > 1
			plugins = arguments
		else if Array.isArray arguments[0]
			plugins = arguments[0]
		else
			plugins = [arguments[0]]

		for name, plugin of plugins
			recess._use plugin