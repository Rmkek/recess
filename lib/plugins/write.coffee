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
				workdir = setting.workdir or cond.workdir or './'

				if (files.length is 1) and (setting.outFile?)
					out = path.resolve  workdir, setting.outFile
					to = punk.d.getExt  out
					rg = punk.d.getType files[0]

					if to isnt rg
						files = await punk.p.to(to)(files, cond)

					# if there is a single file, write its contents to path, which specified in setting.outFile

					await del out
					pn.writeFile out, files[0].contents

				else if files.length is 0
				else if (setting.outDir or setting.outDirectory)
					out = (setting.outDir or setting.outDirectory)
					# if there are multiple files, write they to directory, which specified in setting.outDir
					await punk.d.eachAsync files, (file) ->
						# absolute path
						realPath = path.resolve(workdir, out, file.path)

						await del realPath
						mkdirp.sync path.dirname realPath
						await pn.writeFile realPath, file.contents
						await return
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
