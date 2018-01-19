module.exports = (config, cwd) ->
	path    = require 'path'
	process = require 'process'

	recess =
		filename: config
		dirname:  path.dirname config

		plugins:    {}
		converters: {}
		minifiers:  {}
		fastTasks:  {}

		# TODO: proxy config changes for merge changes with defaults

		config:
			changedDelay: 60#ms

		ignored: []
		ignore: (files) ->
			if files is recess.s.default
				recess.ignored = recess.ignored.concat [ 
					'.git'
					'.nyc_output'
					'.sass-cache'
					'bower_components'
					'coverage'
					'node_modules'
				]
			else
				recess.ignored = recess.ignored.concat files

		_services: []


	# LOAD SEPARATED SCRIPTS

	recess.p = recess.plugins

	require(path.resolve __dirname, './symbols.js')  recess
	require(path.resolve __dirname, './reporter.js') recess
	require(path.resolve __dirname, './dev.js')      recess
	require(path.resolve __dirname, './run-task.js') recess
	require(path.resolve __dirname, './run.js')      recess
	require(path.resolve __dirname, './use.js')      recess
	require(path.resolve __dirname, './file.js')     recess
	require(path.resolve __dirname, './inputs.js')   recess


	#####################
	# ADD BASIC PLUGINS #
	#####################

	recess.use [
		require './plugins/mute.js'
		require './plugins/converter.js'
		require './plugins/minifier.js'
		require './plugins/concat.js'
		require './plugins/wrap-file.js'
		require './plugins/add.js'
		require './plugins/write.js'
		require './plugins/if.js'
		require './plugins/stat.js'
		require './plugins/path.js'
		require './plugins/remove.js'
	]

	return recess

