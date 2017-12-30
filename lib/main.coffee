module.exports = (config) ->
	path    = require 'path'
	process = require 'process'


	cwd    = process.cwd()

	punk =
		filename: config
		dirname:  path.dirname config

		plugins:    {}
		converters: {}
		minifiers:  {}

		# TODO: proxy config changes for merge changes with defaults

		config:
			changedDelay: 60#ms

		symbols:
			entry:      Symbol 'Output to entry.'
			default:    Symbol 'Some default value.'
			isSequence: Symbol 'Some sequence of tasks.'
			isEvent:    Symbol 'Event.' 

		ignored: []
		ignore: (files) ->
			if files is punk.s.default
				punk.ignored = punk.ignored.concat [ 
					'.git'
					'.nyc_output'
					'.sass-cache'
					'bower_components'
					'coverage'
					'node_modules'
				]
			else
				punk.ignored = punk.ignored.concat files


	# LOAD SEPARATED SCRIPTS


	punk.p = punk.plugins
	punk.s = punk.symbols

	require(path.resolve __dirname, './reporter.js') punk
	punk.r = punk.reporter

	require(path.resolve __dirname, './dev.js')      punk
	punk.d = punk.dev

	require(path.resolve __dirname, './run-task.js') punk
	require(path.resolve __dirname, './run.js')      punk
	require(path.resolve __dirname, './use.js')      punk
	require(path.resolve __dirname, './file.js')     punk
	require(path.resolve __dirname, './inputs.js')   punk


	#####################
	# ADD BASIC PLUGINS #
	#####################

	punk.use [
		require './plugins/bundle.js'
		require './plugins/mute.js'
		require './plugins/converter.js'
		require './plugins/minifier.js'
		require './plugins/concat.js'
		require './plugins/wrap-file.js'
		require './plugins/add.js'
		require './plugins/write.js'
	]

	return punk

