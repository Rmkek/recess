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
		convert: (settings) ->
			settings = {format: settings} if typeof settings isnt 'object'

			(files) ->
				for name, file of files
					# get type of file
					tp = type(file)
					unless tp
						tp = {ext: getExt name}
					ext = tp.ext
					ext = 'svg' if isSvg file


					if punk.converters[ext] and punk.converters[ext][settings.format]
						regexp = new RegExp (ext + '$'), 'i'
						newName = name.replace regexp, settings.format
						pipe = punk.converters[ext][settings.format]

						# pipe file
						try
							s = {}
							s[name] = file
							p = pipe s
							if p instanceof Promise
									p.catch (e) -> reporter.error e
									files[newName] = (await p)[name]
								else
									files[newName] = p[name]
							p = bufferize p
						catch e
							reporter.error e				
					else
						# remove file
						delete files[name]
						reporter.noType name

				files
	plugin.to = plugin.convert

	plugin
