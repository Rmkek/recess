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
			(files, cond) ->
				for name, file of files
					# get type of file
					ext = punk.d.getType(name, file)	

					# if there's needed converter
					if punk.minifiers[ext]
						pipe = punk.minifiers[ext]

						f = {}
						f[name] = file

						# pipe file
						files[name] = Buffer.from (await pipe(f, cond))[name]
					else
						# remove file
						delete files[name]
						reporter.noConverter name, ext

				files

	# plugin.pipes.to = plugin.pipes.ex = plugin.pipes.convert

	plugin
