
path    = require 'path'
process = require 'process'


cwd    = process.cwd()
config = process.mainModule.filename

punk =
	filename: config
	dirname:  path.dirname config

	reporter: reporter

	plugins:    {}
	converters: {}
	minifiers:  {}

	# TODO: proxy config changes for merge changes with defaults

	config:
		changedDelay: 60#ms

# LOAD SEPARATED SCRIPTS

Object.assign punk, (require('./reporter.js') punk)
reporter = punk.reporter

Object.assign punk,
	(require('./dev.js')      punk, reporter),
	(require('./run-task.js') punk, reporter),
	(require('./run.js')      punk, reporter),
	(require('./use.js')      punk, reporter),
	(require('./file.js')     punk, reporter)


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
