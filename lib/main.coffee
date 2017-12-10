###################
# CONNECT MODULES #
###################

process  = require 'process'
path     = require 'path'
fs       = require 'fs'
util     = require 'util'

mkdirp   = require 'mkdirp'
glob     = require 'glob'
parallel = require 'run-parallel'
chalk    = require 'chalk'
mdeps    = require 'module-deps'
stp      = require 'stream-to-promise'
isBuffer = require 'is-buffer'
del      = require 'del'
type     = require 'file-type'
rr       = require 'require-resolve'

reporter = require './reporter.js'

####################
# DEFINE VARIABLES #
####################

cwd    = process.cwd()
config = process.mainModule.filename

###########################
# DEFINE HELPER FUNCTIONS #
###########################

exists = (pth) ->
	try
		fs.accessSync pth
		return true
	catch
		return false

setImmediate = setImmediate or (f) ->
	setTimeout f, 0

deps = (file) ->
	new Promise (resolve, reject) ->
		md = mdeps()

		stp(md).then (file) ->
			resolve file

		md.end({ file })

bufferize = (files) ->
	for name, file of files
		unless isBuffer file
			files[name] = Buffer.from file

getExt = (name = '') ->
	ext = path.extname(name).split '.'
	ext[ext.length - 1]

getType = (name, file) ->
	tp = type(file)
	unless tp
		tp = {ext: getExt name}
	ext = tp.ext

#########
# START #
#########

punk =
	filename: config
	dirname:  path.dirname config

	#######
	# RUN #
	#######

	run: (settings) ->
		reporter.start()
		reporter.usingConfig config
		if settings.entry
			settings = [ settings ]

		start = (taskName, setting, cb) ->
			######################################
			# TRANSFORM SETTING TO STANDARD FORM #
			######################################
			setting.pipes = []			    unless setting.pipes?
			setting.pipes = [setting.pipes] unless Array.isArray setting.pipes
			setting.entry = [setting.entry] unless Array.isArray setting.entry

			files = []

			if setting.workdir
				workdir = setting.workdir
			else
				workdir = './'

			reporter.startingTask taskName

			##############
			# FIND FILES #
			##############
			for entry in setting.entry
				continue unless entry
				try
					# get path
					paths = glob.sync entry, cwd: workdir

					for pth in paths
						# read file
						contents = fs.readFileSync path.resolve(workdir, pth)
						files[pth] = contents

			############################
			# PASS FILES THROUGH FILES #
			############################
			for pipe in setting.pipes
				continue unless pipe

				try
					p = pipe files
					if p instanceof Promise
							p.catch (e) -> reporter.error e
							files = await p
						else
							files = p
					p = bufferize p
				catch e
					reporter.error e				

			###########
			# CONVERT #
			###########
			to = setting.outFormat or setting.outExtension or setting.outEx or setting.to
			if to
				try
					p = punk.to(to)(files)
					if p instanceof Promise
							p.catch (e) -> reporter.error e
							files = await p
						else
							files = p
					p = bufferize p
				catch e
					reporter.error e	

			#########
			# WRITE #
			#########
			keys = Object.keys(files)


			if (keys.length is 1) and (setting.outFile?)
				out = setting.outFile
				to = getExt path.resolve(workdir, out)
				rg = getType keys[0], files[keys[0]]

				if to isnt rg
					try
						p = punk.to(to)(files)
						if p instanceof Promise
								p.catch (e) -> reporter.error e
								files = await p
							else
								files = p
						p = bufferize p
					catch e
						reporter.error e	

				# if there is a single file, write its contents to path, which specified in setting.outFile
				del path.resolve(workdir, setting.outFile)
				fs.writeFileSync path.resolve(workdir, setting.outFile), files[keys[0]]

			else if keys.length is 0
			else
				out = (setting.outDir or setting.out or './')
				# if there are multiple files, write they to directory, which specified in setting.outDir
				for name, contents of files
					# absolute path
					realPath = path.resolve(workdir, out, name)

					if exists realPath
						# remove existing file
						del realPath
					mkdirp.sync path.dirname realPath
					fs.writeFileSync realPath, contents

			reporter.finishedTask taskName
			cb()

		###############
		# START BUILD #
		###############
		funcs = []
		for name, setting of settings
			# isolate task from current scope.
			# if this is not done, errors like https://javascript.info/task/make-army can happen
			# there are no "let" in coffeescript, so this is only way
			do (name, setting) ->
				funcs.push (cb) -> 
					t = start name, setting, cb
					t.catch (error) -> reporter.error error

		parallel funcs, ->
			reporter.finishedAll()
			reporter.end()

	reporter: reporter

	# PLUGINS USAGE #

	plugins:    {}
	converters: {}
	minifiers:  {}

	_use: (plugin) ->
		plugin = plugin punk, reporter if typeof plugin is 'function'

		if plugin.pipes
			for name, value of plugin.pipes
				if punk.p[name]
					reporter.error punk.errors.pluginsConflict(name)
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



	# ERRORS #

	errors:
		pluginsConflict: (pluginName) ->
			pl = chalk.blue(pluginName)
			new Error 'Plugin "' + pl + '" conflicts with existing plugin "' + pl + '"!'

punk.p = punk.plugins

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
]

###########
# ALIASES #
###########

punk.to = punk.convert = punk.ex = punk.p.convert
punk.min = punk.minify = punk.p.minify
