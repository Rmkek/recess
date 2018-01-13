path  = require 'path'
type  = require 'file-type'
net   = require 'net'
{ setImmediate } = require 'timers'
deasync = require 'deasync'

module.exports = (recess) ->
	reporter = recess.reporter
	d =
		# CHECK FILE EXISTANCE #
		exists: (pth) ->
			try
				fs.accessSync pth
				return true
			catch
				return false

		# # GET DEPENDENCIES OF JS FILE #
		# deps: (file) ->
		# 	new Promise (resolve, reject) ->
		# 		md = mdeps()

		# 		stp(md).then (file) ->
		# 			resolve file

		# 		md.end({ file })

		prepareFiles: (files) ->
			for index, file of files
				unless file
					files.splice index, 1
				else
					file.contents = Buffer.from file.contents

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
		getType: (file) ->
			tp = type(file.contents)
			unless tp
				tp = {ext: d.getExt file.path}
			ext = tp.ext
			try ext = 'svg' if d.isSvg file.contents
			ext

		# keep process alive
		keepAlive: ->
			unless recess.alive
				net.createServer().listen()
				
			recess.alive = on

		# difference between this functions is that getExt just returns extname, but getType returns true type of file
		# e.g. you can rename pic.png to pic.jpg
		# getExt will say that format is jpg
		# but getType will say that format is png
		# use getType, it's better

		# ASYNC MAP FOR PROMISES #
		mapAsync: (obj, func) ->
			new Promise (resolve, reject) ->
				if Array.isArray obj
					results = []
				else
					results = {}

				if (obj.length is 0) or (Object.keys(obj).length is 0)
					resolve results

				for name, value of obj
					do (name, value) ->
						# async call
						setImmediate ->
							r = func(value, name)
							if r instanceof Promise
								r.catch (err) -> reporter.error err
							results[name] = await r

							if Object.keys(obj).length is Object.keys(results).length
								resolve results

		eachAsync: ->
			@mapAsync arguments...

		toSetting: (inp) ->

			# array syntax to object
			if Array.isArray inp
				r = { }
				for item in inp
					if typeof item is 'object'
						Object.assign r, item

					# add event
					else if (typeof item is 'function') and item[recess.s.isEvent]
						r.start ?= []
						r.start.push item

					# add pipe
					else if (typeof item is 'function') and not item[recess.s.isSequence]
						r.pipes ?= []
						r.pipes.push item

					# add sequence
					else if (typeof item is 'function') and item[recess.s.isSequence]
						r.start ?= []
						r.start.push item

					# add another task
					else if typeof item is 'string'
						r.start ?= []
						r.start.push item
				setting = r
			else
				setting = inp

			setting.pipes   ?= setting.pipe or setting.pipeline or []
			setting.pipes    = [setting.pipes] unless Array.isArray setting.pipes

			setting.start    = setting.start or setting.trigger or setting.trig or setting.then or []
			setting.start    = [setting.start] unless Array.isArray setting.start

			setting.needs = 
				setting.needs     or setting.need   or 
				setting.deps      or setting.dep    or setting.depend  or setting.depends or setting.dependOn or 
				setting.dependsOn or setting.invoke or setting.invokes

			setting.needs = [setting.start] unless Array.isArray setting.start

			setting.entry   ?= setting.entries or setting.input or setting.inputs  or []
			setting.entry    = [setting.entry] unless Array.isArray setting.entry

			setting.outFile ?= setting.outFiles or []
			setting.outFile  = [setting.outFile] unless Array.isArray setting.outFile

			setting.outDir  ?= setting.outDirs or []
			setting.outDir   = [setting.outDir] unless Array.isArray setting.outDir

			setting.workdir  = setting.workdir or setting.dir   or setting.dirname or './'

			if setting.workdir
				setting.workdir = path.resolve(recess.dirname, setting.workdir)
			else
				setting.workdir = path.resolve(recess.dirname)

			setting

		isSvg: (s) ->
			comments = /<!--([\s\S]*?)-->/gi
			svg = /^\s*(?:<\?xml[^>]*>\s*)?(?:<!doctype svg[^>]*\s*(?:<![^>]*>)*[^>]*>\s*)?<svg[^>]*>[^]*<\/svg>\s*$/i

			svg.test(s.toString().replace(comments, ''))

		sleep: (time) ->
			new Promise (r, j) ->
				setTimeout ->
					r()
				, time

		flat: (f) ->
			flat = (arr, res) ->
				i = 0
				cur = undefined
				len = arr.length
				while i < len
					cur = arr[i]
					if Array.isArray(cur) then flat(cur, res) else res.push(cur)
					i++
				res
			flat f, []

		await: (p) ->
			finished = false
			r = undefined
			p.then (rs) -> 
				finished = true
				r = rs
			deasync.loopWhile -> not finished
			r

		once: do ->
			did = []

			(f, args = [], context) ->
				if not did.indexOf f
					if context
						await f.apply(context, args)
					else
						await f args...
					did.push f

	recess.dev = d
	recess.d   = d
