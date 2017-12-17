Mode = require 'stat-mode'

module.exports = (punk, reporter) ->
	File: class 
		constructor: (  @path, 
						@contents = new Buffer(''), 
						stat      = 0o777
					) ->

			unless Buffer.isBuffer @contents
				@contents = Buffer.from @contents

			@stat = new Mode mode: stat

