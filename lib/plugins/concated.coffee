
path       = require 'path'
fs         = require 'fs-extra'
globby     = require 'globby'
ignore     = require 'ignore'
path       = require 'path'
browserify = require 'browserify'
babelify   = require 'babelify'
mm         = require 'micromatch'
path       = require 'path'
relative   = require 'relative'
path       = require 'path'
fs         = require 'fs-extra'
assign     = require 'deep-assign'
Mode       = require 'stat-mode'
path       = require 'path'
fs         = require 'fs-extra'

normalize = (mode) ->
	called = false
	newMode = 
		owner: {}
		group: {}
		others: {}
	for key in ['read', 'write', 'execute'] when typeof mode[key] == 'boolean'
		newMode.owner[key] = mode[key]
		newMode.group[key] = mode[key]
		newMode.others[key] = mode[key]
		called = true

	if called then newMode else mode

module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		add: (settings) =>
				settings = [settings] unless Array.isArray settings

				# PIPE #
				recess.i.any (files, cond) ->
					# get paths
					unless settings.length is 0
						ig = ignore().add recess.ignored
						glb   = globby.sync settings, cwd: cond.workdir
						paths = ig.filter glb

						# no files at input
						if (paths.length is 0) and (glb.length is paths.length)
							reporter.noFiles settings

						# load files
						await recess.d.eachAsync paths, (pth) ->
							contents = await fs.readFile(path.resolve cond.workdir, pth)
							files.push ( new recess.File pth, contents )
							await return

					files


		bundle: (bws = { presets: [ "env", "vue-app" ] }, bbs) ->
			# PIPE #
			recess.i.stream (files) ->
				await recess.d.eachAsync files, (file) ->
					new Promise (resolve, reject) ->
						# new browserify bundle
						
						bws2 = Object.assign (basedir: path.dirname file.path), bws

						bundle = browserify file.contents, bws # set cwd to file name

						# add babelify
						bundle.transform babelify, bbs

						# start bundling
						bundle.bundle (err, b) ->
							# throw error
							reporter.error err if err

							file.contents = b
							resolve()
				files

		concat: (settings, separator) ->
			# set settings to standard form
			if separator? and typeof settings isnt 'object'
				settings = { output: settings, separator: separator }
			else if typeof settings isnt 'object'
				settings = { output: settings, separator: '' }
			else
				reporter.error new Error 'Settings not defined!' 

			# PIPE #
			recess.i.buffer (files) ->

				separator = Buffer.from settings.separator

				# buffer concat list
				joinList = []

				for file in files
					joinList.push file.contents, separator
				joinList.pop()

				out = Buffer.concat joinList

				# new file storage
				r = []
				r.push new recess.File( settings.output, out )

				return r


		convert: (settings, tr) ->
			if typeof settings not in ['number', 'string']
				reporter.error 'Setting must be a number or string!'


			recess.i.buffer (files, cond) ->
				r = await recess.d.mapAsync files, (file) ->
					ext = recess.d.getType file

					# if there's needed converter
					if recess.converters[ext] and recess.converters[ext][settings]

						pipe = recess.converters[ext][settings]

						collection = recess.collection [file], cond
						await collection.pipe pipe

						file = collection.files[0]
						file.setExt settings

						# pipe file
						return file
					else if ext is settings
						return file
					else if tr
					else
						# remove file
						reporter.noConverter file.path, settings
						return file
				r


		pif: (settings) ->
			recess.i.any (files, cond) ->

				await recess.d.eachAsync settings, (pipe, name) ->
					keys = (file.path for file in files)
					filtered = mm keys, name

					for flt in filtered
						file = file for id, file of files when file.path is flt
						collection = recess.collection [file], cond
						await collection.pipe pipe
						file = collection.files[0]
						files[id] = file

				files


		minify: (settings) ->
			recess.i.buffer (files, cond) ->
				r = await recess.d.mapAsync files, (file) ->
					ext = recess.d.getType file

					# if there's needed converter
					if recess.minifiers[ext]

						# find converter
						pipe = recess.minifiers[ext]

						collection = recess.collection [file], cond
						await collection.pipe pipe

						file = collection.files[0]

						# pipe file
						return file
					else
						# remove file
						reporter.noMin file.path
						return
				r


		mute: (files)-> 
			if files
				[]
			else
				-> []

		wrap: (settings) =>
				# PIPE #
				recess.i.any (files, cond) ->
					for file in files
						file.path = relative cond.workdir, file.path
						file.path = path.join settings, file.path
					files

		unwrap: (reg, str = "") =>
				# PIPE #
				recess.i.any (files, cond) ->
					xp = new RegExp reg + '/?'
					for file in files
						file.path = file.path.replace xp, str
					files

		del: ->
			recess.i.any (files, cond) ->
				await recess.d.eachAsync files, (file) ->
					pth = path.resolve cond.workdir, file.path
					await fs.remove pth

				files


		stat: (stat) ->
			if typeof stat is 'object'
				stat = normalize stat

			recess.i.any (files, cond) ->
				for file in files

					if typeof stat is 'number'
						file.stat = stat
					else	
						assign file.stat, stat
				files


		header: (settings) ->
			recess.i.buffer (files, cond) ->
				b = Buffer.from settings
				await recess.d.eachAsync files, (file) ->
					file.contents = Buffer.concat [b, file.contents]
				files
		footer: (settings) ->
			recess.i.buffer (files, cond) ->
				b = Buffer.from settings
				await recess.d.eachAsync files, (file) ->
					file.contents = Buffer.concat [file.contents, b]
				files

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
	plugin.pipes.load = plugin.pipes.add
	plugin.pipes.mode = plugin.pipes.stat
	plugin.pipes.remove = plugin.pipes.del
	plugin.pipes.min = plugin.pipes.minify
	plugin.pipes.if = plugin.pipes.cluster = plugin.pipes.pif
	plugin.pipes.to = plugin.pipes.ex = plugin.pipes.convert
	plugin.pipes.rename = plugin.pipes.concat

	plugin
