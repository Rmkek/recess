###################
# CONNECT MODULES #
###################

process  = require 'process'
path     = require 'path'
fs       = require 'fs'
util     = require 'util'

####################
# DEFINE VARIABLES #
####################

cwd    = process.cwd()
config = process.mainModule.filename

punk =

	filename: config
	dirname:  path.dirname config

	reporter: reporter

	plugins:    {}
	converters: {}
	minifiers:  {}



# LOAD SEPARATED SCRIPTS

Object.assign punk, (require('./reporter.js') punk)
reporter = punk.reporter

Object.assign punk, (require('./dev.js')      punk, reporter)
Object.assign punk, (require('./run-task.js') punk, reporter)
Object.assign punk, (require('./run.js')      punk, reporter)
Object.assign punk, (require('./watch.js')    punk, reporter)
Object.assign punk, (require('./use.js')      punk, reporter)

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
