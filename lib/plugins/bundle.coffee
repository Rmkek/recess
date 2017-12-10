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


					bnd = (name, contents) ->
						# new browserify bundle
						bundle = browserify streamify(contents), basedir: path.dirname name # set cwd to file name

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
							files[name] = b.toString()

							finished++

							# when all bundles are finished
							if finished is bundles
								# next pipe
								resolve files

					# bind each file
					for name, contents of files
						bnd name, contents
	plugin