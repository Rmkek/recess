# REQUIRED MODULES #
path       = require 'path'
browserify = require 'browserify'
babelify   = require 'babelify'
util   = require 'util'

module.exports = (recess) ->
	reporter = recess.reporter
	plugin = {}
	plugin.pipes =
		bundle: (bws = { presets: [ "env", "vue-app" ] }, bbs) ->
			# PIPE #
			recess.i.stream (files, cond) ->
				await recess.d.eachAsync files, (file) ->
					new Promise (resolve, reject) ->
						# new browserify bundle
						bws2 = Object.assign (basedir: path.resolve(cond.workdir, path.dirname file.path)), bws
						# reporter.fatal util.format bws2

						bundle = browserify file.contents, bws2 # set cwd to file name

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