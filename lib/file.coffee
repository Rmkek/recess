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

	punk.Collection = class
		constructor: (@files = [], @settings = {}) ->

		_pipe = (p) ->
			r = await p @files, @settings
			@files = r
			await return @files

		pipe: (pipe) ->
			sf = @

			p = new Promise (resolve, reject) ->
				sf.files = (await pipe sf.files, sf.settings) or sf.files
				resolve sf.files

			p.pipe = -> 
				args = arguments
				p.then ->
					sf.pipe args...

			p


