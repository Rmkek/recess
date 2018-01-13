path = require 'path'
fs   = require 'fs-extra'

module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		write: (setting) ->

			# PIPE #
			recess.i.buffer (files, cond) ->
				workdir = setting.workdir or cond.workdir or './'

				if files.length is 1 and setting.outFile?.length

					if setting.outFile[0] is recess.s.entry
						setting.outFile = setting.entry

					await recess.d.eachAsync setting.outFile, (pth) ->
						out = path.resolve   workdir, pth
						to  = recess.d.getExt  out
						rg  = recess.d.getType files[0]

						if to isnt rg
							files = await recess.p.to(to, false)(files, cond)

						await fs.remove out
						await fs.writeFile out, files[0].contents, mode: files[0].stat.stat.mode

				else if files.length is 0

				else if setting.outDir?.length
					out = (setting.outDir or setting.outDirectory)

					# if there are multiple files, write they to directory, which specified in setting.outDir
					await recess.d.eachAsync out, (dir) ->

						await recess.d.eachAsync files, (file) ->
							# absolute path
							realPath = path.resolve(workdir, dir, file.path)

							await fs.remove realPath

							await fs.mkdirp path.dirname realPath

							await fs.writeFile realPath, file.contents, mode: files[0].stat.stat.mode
							await return
				files

		outFile: (setting) ->
			setting = [setting] unless Array.isArray setting
			(files, cond) ->
				await plugin.pipes.write(outFile: setting)(files, cond)

		outDir: (setting) ->
			setting = [setting] unless Array.isArray setting
			(files, cond) ->
				await plugin.pipes.write(outDir: setting)(files, cond)

	plugin.pipes.outDirectory = plugin.pipes.outDir
	plugin.pipes.dest = plugin.pipes.write

	plugin
