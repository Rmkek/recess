# REQUIRED MODULES #
stream     = require 'stream'
path       = require 'path'
browserify = require 'browserify'
babelify   = require 'babelify'

# create stream from buffer
streamify = (b) ->
	s = new stream.Readable
	s.push b
	s.push null
	s

module.exports = (punk, reporter) ->
	plugin = {}
	plugin.pipes =
		bundle: (settings) ->
			# PIPE #
			(files) ->
				new Promise (resolve, reject) ->
					bundles  = 0
					finished = 0


					bnd = (file) ->
						# new browserify bundle
						bundle = browserify streamify(file.contents), basedir: path.dirname file.path # set cwd to file name

						# add babelify
						bundle.transform babelify, { presets: [ "env", "vue-app" ] }

						bundles++

						# start bundling
						bundle.bundle (err, b) ->

							# throw error
							if err
								console.error err
								process.exit()

							# write file
							files[files.indexOf file] = file

							finished++

							# when all bundles are finished
							if finished is bundles
								# next pipe
								resolve files


					await punk.d.mapAsync files, (file) ->
						await bnd file

	plugin