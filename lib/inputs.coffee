sta = require 'stream-to-array'
stream = require 'stream'

module.exports = (punk) ->

	punk.i = punk.inputs = punk.input = {}

	type = (obj) ->
		if typeof obj is 'string'
			'string'
		else if Buffer.isBuffer obj
			'buffer'
		else if (typeof obj is 'object') and obj.pipe?
			'stream'
		else
			punk.reporter.error 'Unknown type of file contents!'

	punk.i.buffer = (f) ->
		(files) ->
			await punk.d.eachAsync files, (file, name) ->
				tp = type file.contents

				if tp is 'string'
					modified = Buffer.from file.contents

				else if tp is 'buffer'
					modified = file.contents

				else if tp is 'stream'
					arr = await sta file.contents
					arr = await punk.d.mapAsync arr, (contents) -> Buffer.from contents
					modified = Buffer.contents arr	

				files[name].contents = modified

			f arguments...

	punk.i.string = (f) ->
		(files) ->
			await punk.d.eachAsync files, (file, name) ->
				tp = type file.contents

				if tp is 'string'
					modified = file.contents

				else if tp is 'buffer'
					modified = file.contents.toString()

				else if tp is 'stream'
					arr = await sta file.contents
					arr = await punk.d.mapAsync arr, (contents) -> contents.toString()
					modified = arr.join ''

				files[name].contents = modified

			f arguments...

	streamify = (b) ->
		s = new stream.Readable
		s.push b
		s.push null
		s

	punk.i.stream = (f) ->
		(files) ->
			await punk.d.eachAsync files, (file, name) ->
				tp = type file.contents

				if tp is 'string'
					modified = streamify file.contents

				else if tp is 'buffer'
					modified = streamify file.contents

				else if tp is 'stream'
					modified = file.contents

				files[name].contents = modified

			f arguments...

	punk.i.any = (f) ->
		->
			f arguments...


