path = require 'path'
fs   = require 'fs'
del  = require 'del'
mkdirp = require 'mkdirp'
pn = require 'pn/fs'

module.exports = (punk, reporter) ->
	plugin = {}
	plugin.pipes =
		write: (setting) ->

			# PIPE #
			(files, cond) ->
				keys = Object.keys(files)

				workdir = setting.workdir or cond.workdir or './'

				if (keys.length is 1) and (setting.outFile?)
					fn = keys[0]
					out = path.resolve workdir, setting.outFile
					to = punk.d.getExt out
					rg = punk.d.getType keys[0], files[keys[0]]

					if to isnt rg
						files = await punk.p.to(to)(files, cond)

					# if there is a single file, write its contents to path, which specified in setting.outFile

					pn.writeFile out, files[Object.keys(files)[0]]

				else if keys.length is 0
				else if (setting.outDir or setting.outDirectory)
					out = (setting.outDir or setting.outDirectory)
					# if there are multiple files, write they to directory, which specified in setting.outDir
					for name, contents of files
						# absolute path
						realPath = path.resolve(workdir, out, name)

						mkdirp.sync path.dirname realPath
						pn.writeFile realPath, contents
				files

		outFile: (setting) ->
			(files, cond) ->
				await plugin.pipes.write(outFile: setting)(files, cond)

		outDir: (setting) ->
			(files, cond) ->
				await plugin.pipes.write(outDir: setting)(files, cond)

	plugin.pipes.outDirectory = plugin.pipes.outDir
	plugin.pipes.dest = plugin.pipes.write

	plugin
