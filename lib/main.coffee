
path    = require 'path'
process = require 'process'


cwd    = process.cwd()
config = process.mainModule.filename

punk =
	filename: config
	dirname:  path.dirname config

	plugins:    {}
	converters: {}
	minifiers:  {}

	# TODO: proxy config changes for merge changes with defaults

	config:
		changedDelay: 60#ms

# LOAD SEPARATED SCRIPTS

require('./reporter.js') punk
require('./dev.js')      punk
require('./run-task.js') punk
require('./run.js')      punk
require('./use.js')      punk
require('./file.js')     punk
require('./inputs.js')   punk


punk.p = punk.plugins
punk.d = punk.dev

module.exports = punk

#####################
# ADD BASIC PLUGINS #
#####################

punk.use [
	require './plugins/bundle.js'
	require './plugins/mute.js'
	require './plugins/converter.js'
	require './plugins/minifier.js'
	require './plugins/concat.js'
	require './plugins/add.js'
	require './plugins/write.js'
]


