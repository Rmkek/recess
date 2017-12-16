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
			(files, cond) ->
				for name, file of files
					ext = punk.d.getType(name, file)	


					# if there's needed converter
					if punk.converters[ext] and punk.converters[ext][settings]
						regexp = new RegExp (ext + '$'), 'i'
						newName = name.replace regexp, settings
						pipe = punk.converters[ext][settings]

						# pipe file
						files[newName] = Buffer.from (await pipe(files, cond))[name]
						delete files[name]
					else
						# remove file
						delete files[name]
						reporter.noConverter name, ext

				files

	plugin.pipes.to = plugin.pipes.ex = plugin.pipes.convert

	plugin
