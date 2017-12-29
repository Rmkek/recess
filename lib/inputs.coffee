module.exports = (punk) ->
	punk.inputs = punk.i = punk.input = 
		buffer: (f) ->
			(files) ->
				await punk.d.eachAsync files, (file) ->
					file.contents = Buffer.from file.contents
				f arguments... 

		string: (f) ->
			(files) ->
				await punk.d.eachAsync files, (file) ->
					file.contents = file.contents.toString()
				f arguments... 



