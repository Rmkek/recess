mdeps = require 'module-deps'
fs    = require 'fs'
path  = require 'path'
type  = require 'file-type'
stp   = require 'stream-to-promise'
svg   = require 'is-svg'
{ setImmediate } = require 'timers'

module.exports = (punk, reporter) ->
	d =
		# CHECK FILE EXISTANCE #
		exists: (pth) ->
			try
				fs.accessSync pth
				return true
			catch
				return false

		# GET DEPENDENCIES OF JS FILE #
		deps: (file) ->
			new Promise (resolve, reject) ->
				md = mdeps()

				stp(md).then (file) ->
					resolve file

				md.end({ file })

		# BUFFERIZE FILES #
		bufferizeFiles: (files) ->
			for name, file of files
				files[name] = Buffer.from file
			return files

		toPromise: (f) ->
			if f instanceof Promise
				f
			else
				new Promise (resolve, reject) ->
					try
						resolve f
					catch e
						reject e

		# GET EXTNAME OF FILE #
		getExt: (name = '') ->
			ext = path.extname(name).split '.'
			ext[ext.length - 1]

		# GET TYPE OF FILE #
		getType: (name, file) ->
			tp = type(file)
			unless tp
				tp = {ext: d.getExt name}
			ext = tp.ext
			try ext = 'svg' if svg file
			ext

		# difference between this functions is that getExt just returns extname, but getType returns true type of file
		# e.g. you can rename pic.png to pic.jpg
		# getExt will say that format is jpg
		# but getType will say that format is png
		# use getType, it's better

		# ASYNC MAP FOR PROMISES #
		mapAsync: (obj, func, cb = ->) ->
			new Promise (resolve, reject) ->
				ir = Array.isArray obj
				if ir
					results = []
				else
					results = {}

				if obj.length is 0
					resolve results


				for name, value of obj
					name = name - 0 if ir
					do (name, value) ->
						# async call
						setImmediate ->
							r = func(value, name)
							if r instanceof Promise
								r.catch (err) -> reporter.error err
							results[name] = await r

							if Object.keys(obj).length is Object.keys(results).length
								resolve results

		eachAsync: (obj, func, cb = ->) ->
			new Promise (resolve, reject) ->
				tasks = 0
				finished = 0
				for name, value of obj
					name = name - 0 if ir
					do (name, value) ->
						tasks++
						setImmediate ->
							r = func(value, name)
							if r instanceof Promise
								r.catch (err) -> reporter.error err
							results[name] = await r
							finished++

							if tasks is finished
								resolve results

		toSetting: (inp) ->
			# array to object
			if Array.isArray inp
				r = { }
				for item in inp
					if typeof item is 'object'
						Object.assign r, item
					else if typeof item is 'function'
						r.pipes ?= []
						r.pipes.push item
				setting = r
			else
				setting = inp

			setting.pipes   ?= setting.pipe or setting.pipeline or []
			setting.pipes    = [setting.pipes] unless Array.isArray setting.pipes

			setting.entry   ?= setting.entries or setting.input or setting.inputs  or []
			setting.workdir  = setting.workdir or setting.dir   or setting.dirname or './'

			if setting.workdir
				setting.workdir = path.resolve(punk.dirname, setting.workdir)
			else
				setting.workdir = path.resolve(punk.dirname)

			setting

	{ dev: d }
