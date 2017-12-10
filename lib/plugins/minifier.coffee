type     = require 'file-type'
path     = require 'path'
chalk    = require 'chalk'
isSvg    = require 'is-svg'
isBuffer = require 'is-buffer'

bufferize = (files) ->
	for name, file of files
		unless isBuffer file
			files[name] = Buffer.from file

getExt = (name = '') ->
	ext = path.extname(name).split '.'
	ext[ext.length - 1]

module.exports = (punk, reporter) ->
	plugin = {}
	plugin.pipes =
		minify: (settings) ->
			settings = {format: settings} if typeof settings isnt 'object'

			(files) ->
				for name, file of files
					# get type of file
					tp = type(file)
					unless tp
						tp = {ext: getExt name}
					ext = tp.ext
					ext = 'svg' if isSvg file


					if punk.minifiers[ext]
						pipe = punk.minifiers[ext]
						# pipe file
						try
							s = {}
							s[name] = file
							p = pipe s
							if p instanceof Promise
									p.catch (e) -> reporter.error e
									files[name] = (await p)[name]
								else
									files[name] = p[name]
							p = bufferize p
						catch e
							reporter.error e				
					else
						# remove file
						delete files[name]
						reporter.noMin name

				files
	plugin.min = plugin.minify

	plugin
