Mode = require 'stat-mode'

module.exports = (recess) ->
	reporter = recess.reporter
	recess.File = class 
		constructor: (  @path, 
						@contents = new Buffer(''), 
						stat      = 0o777
					) ->

			unless Buffer.isBuffer @contents
				@contents = @contents or ''
				@contents = Buffer.from @contents

			stat = new Mode mode: stat

			Object.defineProperty @, 'stat',
				get: -> stat
				set: (s) ->
					stat = new Mode mode: s
				enumerable: true

			Object.defineProperty @, 'mode',
				get: -> stat
				set: (s) ->
					stat = new Mode mode: s
				enumerable: true

		toString: ->
			"<File #{@path}: #{@contents}>"

		setExt: (newExt) ->
			reporter.error 'ext is undefined' unless newExt?

			ext = recess.d.getType @
			regexp = new RegExp (ext + '$'), 'i'
			newName = @path.replace regexp, newExt
			@path = newName

	# recess.Collection = class
	# 	constructor: (@files = [], @settings = {}) ->
	# 		@settings.workdir ?= recess.dirname

	# 	_pipe = (p) ->
	# 		r = await p @files, @settings
	# 		@files = r
	# 		await return @files

	# 	pipe: (pipe) ->
	# 		sf = @

	# 		p = new Promise (resolve, reject) ->
	# 			if typeof pipe is 'function'
	# 				sf.files = (await pipe sf.files, sf.settings)
	# 				sf.files = sf.files or []
	# 			resolve sf.files

	# 		p.pipe = -> 
	# 			args = arguments
	# 			p.then ->
	# 				sf.pipe args...

	# 		p

	# 	th: (pipe) ->
	# 		recess.d.await @pipe pipe

	recess.collection = (files = [], settings = {}) ->
		settings.workdir ?= recess.dirname

		coll = (pipe) ->
			recess.d.await coll.pipe pipe 

		coll.files    = files
		coll.settings = settings

		coll.th = coll.through = coll

		coll.pipe = (pipe) ->
			p = new Promise (resolve, reject) ->
				if typeof pipe is 'function'
					try

						r = await pipe coll.files, coll.settings
						
						if typeof r isnt 'object'
							reporter.error 'Result of pipe must be an array! Got ' + typeof pipe + '.'

						coll.files = await r or coll.files

					catch e
						reporter.error e
				else
					reporter.error 'Pipe must be a function! Got ' + typeof pipe + '.'

				resolve coll.files

			p.pipe = -> 
				args = arguments
				p.then ->
					coll.pipe args...

			p

		coll




