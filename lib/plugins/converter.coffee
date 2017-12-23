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
				r = await punk.d.mapAsync files, (file) ->
					ext = punk.d.getType file

					# if there's needed converter
					if punk.converters[ext] and punk.converters[ext][settings]

						# get new name
						regexp = new RegExp (ext + '$'), 'i'
						newName = file.path.replace regexp, settings
						
						pipe = punk.converters[ext][settings]

						r = await pipe([file], cond)
						nc = Buffer.from(r[0].contents)

						# pipe file
						return new punk.File file.path, nc
					else
						# remove file
						reporter.noConverter file.path, ext
						return
				r

	plugin.pipes.to = plugin.pipes.ex = plugin.pipes.convert

	plugin
