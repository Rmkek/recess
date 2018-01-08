Mode = require 'stat-mode'

module.exports = (punk) ->
	reporter = punk.reporter
	punk.File = class 
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
					stat = new Mode mode: stat

		toString: ->
			"<File #{@path}: #{@contents}"

	# punk.Collection = class
	# 	constructor: (@files = [], @settings = {}) ->
	# 		@settings.workdir ?= punk.dirname

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
	# 		punk.d.await @pipe pipe

	punk.collection = (files = [], settings = {}) ->
		settings.workdir ?= punk.dirname

		coll = (pipe) ->
			punk.d.await coll.pipe pipe 

		coll.files    = files
		coll.settings = settings

		coll.th = coll.through = coll

		coll._pipe = (p) ->
			r = await p coll.files, coll.settings
			coll.files = r
			await return coll.files

		coll.pipe = (pipe) ->
			p = new Promise (resolve, reject) ->
				if typeof pipe is 'function'
					coll.files = (await pipe coll.files, coll.settings)
					coll.files = coll.files or []
				resolve coll.files

			p.pipe = -> 
				args = arguments
				p.then ->
					coll.pipe args...

			p

		coll




