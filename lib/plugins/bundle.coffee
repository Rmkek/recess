# REQUIRED MODULES #
path       = require 'path'
browserify = require 'browserify'
babelify   = require 'babelify'

module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
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

	plugin